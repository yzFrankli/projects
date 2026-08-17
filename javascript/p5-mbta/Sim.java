import java.io.*;
import java.util.*;
import java.util.concurrent.locks.*;

public class Sim {

  public static void run_sim(MBTA mbta, Log log) {
    // Ensure MBTA runtime state is initialized (creates stationStates, waiting, onboard, trainLocation, etc).
    // initRuntimeState may already be called by mbta.loadConfig(); calling again is harmless.
    mbta.initRuntimeState();

    List<Thread> threads = new ArrayList<>();
    List<Thread> trainThreads = new ArrayList<>();
    List<Thread> passThreads = new ArrayList<>();

    // create train threads (assume mbta.lineObj keys exist)
    for (Train t : mbta.lineObj.keySet()) {
      TrainThread tt = new TrainThread(mbta, t, log);
      threads.add(tt);
      trainThreads.add(tt);
    }

    // create passenger threads
    for (Passenger p : mbta.tripObj.keySet()) {
      PassThread pt = new PassThread(mbta, p, log);
      threads.add(pt);
      passThreads.add(pt);
    }

    // start all threads
    for (Thread th : threads) th.start();

    // wait for passengers to finish
    for (Thread th : passThreads) {
      try {
        th.join();
      } catch (InterruptedException e) {
        Thread.currentThread().interrupt();
        break;
      }
    }

    // stop trains: interrupt and join
    for (Thread th : trainThreads) th.interrupt();
    for (Thread th : trainThreads) {
      try {
        th.join();
      } catch (InterruptedException e) {
        Thread.currentThread().interrupt();
      }
    }
  }

  public static void main(String[] args) throws Exception {
    if (args.length != 1) {
      System.out.println("usage: ./sim <config file>");
      System.exit(1);
    }

    MBTA mbta = new MBTA();
    mbta.loadConfig(args[0]);

    Log log = new Log();

    run_sim(mbta, log);

    String s = new LogJson(log).toJson();
    PrintWriter out = new PrintWriter("log.json");
    out.print(s);
    out.close();

    mbta.reset();
    mbta.loadConfig(args[0]);
    Verify.verify(mbta, log);
  }
}

/* Passenger thread:
   - For each leg, wait at current station for a suitable train (train at same station and its line contains next station).
   - Board (move passenger from waiting set to onboard set) under station lock.
   - Wait for boarded train to arrive at destination station, then deboard under destination station lock.
   Important: do NOT create new keys in mbta maps here. Rely on mbta.initRuntimeState() to have created sets.
*/
class PassThread extends Thread {
  MBTA mbta;
  Passenger pass;
  Log log;

  public PassThread(MBTA mbta, Passenger pass, Log log) {
    this.mbta = mbta;
    this.pass = pass;
    this.log = log;
  }

  @Override
  public void run() {
    List<Station> trip = mbta.tripObj.get(pass);
    if (trip == null || trip.size() < 2) return;

    for (int leg = 0; leg < trip.size() - 1; ++leg) {
      Station cur = trip.get(leg);
      Station dest = trip.get(leg + 1);

      MBTA.StationState curState = mbta.stationStates.get(cur);
      MBTA.StationState destState = mbta.stationStates.get(dest);

      if (curState == null || destState == null) {
        // initRuntimeState should have created them; fail fast for clearer debugging
        throw new IllegalStateException("Missing StationState for station in trip: " + cur + " or " + dest);
      }

      Train boardedTrain = null;

      // Wait at current station for a train to board
      curState.lock.lock();
      try {
        // waiting set must exist and be mutable (created by initRuntimeState)
        Set<Passenger> wset = mbta.waiting.get(cur);
        if (wset == null) {
          throw new IllegalStateException("waiting set missing for station " + cur);
        }
        // Ensure the passenger is listed as waiting at the start of this leg.
        // initRuntimeState should have inserted them; if not, add here (but we assume initRuntimeState is correct).
        if (!wset.contains(pass)) {
          // Defensive: add only if it's a real mutable set created by initRuntimeState()
          wset.add(pass);
        }

        while (true) {
          if (Thread.currentThread().isInterrupted()) return;

          Train t = curState.currentTrain;
          if (t != null) {
            // only allow boarding if this train's line contains the destination station
            List<Station> line = mbta.lineObj.get(t);
            if (line != null && line.indexOf(dest) >= 0 && line.indexOf(cur) >= 0) {
              // board this train: remove from waiting set, add to onboard set
              wset.remove(pass);

              Set<Passenger> on = mbta.onboard.get(t);
              if (on == null) {
                throw new IllegalStateException("onboard set missing for train " + t);
              }
              on.add(pass);

              // mark passenger location as onboard (null)
              mbta.passLocation.put(pass, null);

              log.passenger_boards(pass, t, cur);
              boardedTrain = t;
              break;
            }
          }

          try {
            curState.changed.await();
          } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            return;
          }
        }
      } finally {
        curState.lock.unlock();
      }

      if (boardedTrain == null) return;

      // Wait until boardedTrain reaches dest, then deboard
      boolean deboarded = false;
      while (!deboarded) {
        destState.lock.lock();
        try {
          Train trainHere = destState.currentTrain;
          if (trainHere == boardedTrain) {
            // perform deboard
            Set<Passenger> on = mbta.onboard.get(boardedTrain);
            if (on == null) {
              throw new IllegalStateException("onboard set missing for train " + boardedTrain);
            }
            on.remove(pass);

            mbta.passLocation.put(pass, dest);

            Set<Passenger> wsetDest = mbta.waiting.get(dest);
            if (wsetDest == null) {
              throw new IllegalStateException("waiting set missing for station " + dest);
            }
            wsetDest.add(pass);

            log.passenger_deboards(pass, boardedTrain, dest);

            // signal others waiting at dest
            destState.changed.signalAll();
            deboarded = true;
            break;
          } else {
            try {
              destState.changed.await();
            } catch (InterruptedException e) {
              Thread.currentThread().interrupt();
              return;
            }
          }
        } finally {
          destState.lock.unlock();
        }
      }
    }
  }
}

/* Train thread:
   - Move train along its line in sequence, reversing direction at ends.
   - Acquire the two station locks in lexicographic order of station names (to match verifier expectation).
   - While the destination station is occupied by another train, wait on that station's condition.
   - Do the move atomically (update both StationState.currentTrain and mbta.trainLocation) while holding both locks.
   - Signal both stations after move; then release locks and sleep 10 ms (without holding locks).
*/
class TrainThread extends Thread {
  MBTA mbta;
  Train train;
  Log log;

  public TrainThread(MBTA mbta, Train train, Log log) {
    this.mbta = mbta;
    this.train = train;
    this.log = log;
  }

  @Override
  public void run() {
    List<Station> line = mbta.lineObj.get(train);
    if (line == null || line.size() < 2) return;

    Station loc = mbta.trainLocation.get(train);
    int index = (loc == null) ? 0 : line.indexOf(loc);
    if (index < 0) index = 0;
    int dir = +1;

    while (!Thread.currentThread().isInterrupted() && mbta.passengersActive()) {
      int nextIndex = index + dir;
      if (nextIndex < 0 || nextIndex >= line.size()) {
        dir = -dir;
        nextIndex = index + dir;
      }

      Station s1 = line.get(index);
      Station s2 = line.get(nextIndex);

      MBTA.StationState st1 = mbta.stationStates.get(s1);
      MBTA.StationState st2 = mbta.stationStates.get(s2);

      if (st1 == null || st2 == null) {
        throw new IllegalStateException("Missing StationState for " + s1 + " or " + s2);
      }

      // Determine lock order by station name lexicographic order (consistent global order)
      MBTA.StationState first = (s1.toString().compareTo(s2.toString()) <= 0) ? st1 : st2;
      MBTA.StationState second = (first == st1) ? st2 : st1;

      first.lock.lock();
      try {
        second.lock.lock();
        try {
          // validate that this train is still at s1
          if (st1.currentTrain != train) {
            // something changed; it's safer to abort this train thread
            return;
          }

          // wait while s2 is occupied by another train
          while (st2.currentTrain != null && st2.currentTrain != train) {
            try {
              st2.changed.await();
            } catch (InterruptedException ie) {
              Thread.currentThread().interrupt();
              return;
            }
          }

          // perform move atomically
          st1.currentTrain = null;
          st2.currentTrain = train;
          mbta.trainLocation.put(train, s2);

          log.train_moves(train, s1, s2);

          // notify waiters on both stations
          st2.changed.signalAll();
          st1.changed.signalAll();

        } finally {
          second.lock.unlock();
        }
      } finally {
        first.lock.unlock();
      }

      // sleep 10 ms without holding station locks
      try {
        Thread.sleep(10);
      } catch (InterruptedException ie) {
        Thread.currentThread().interrupt();
        return;
      }

      index = nextIndex;
    }
  }
}