import java.io.File;
import java.io.FileNotFoundException;
import java.util.*;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.ReentrantLock;

import com.google.gson.*;
import com.google.gson.reflect.*;

public class MBTA {
  // raw string form (for the GSON reader)
  public Map <String, List<String>> lines = new HashMap<>();
  public Map <String, List<String>> trips = new HashMap<>();
  
  // object form needed by verifier & simulator

  // each train
  public Map <Train, List<Station>> lineObj = new HashMap<>();

  // passenger and trip as object
  public Map <Passenger, List<Station>> tripObj = new HashMap<>();

  // trains at each station
  public Map <Station, Set<Train>> TrainsAtStation = new HashMap<>();

  // where each train is
  public Map <Train, Station> trainLocation = new HashMap<>();

  // passenger curr station (should contain all passengers)
  public Map <Passenger, Station> passLocation = new HashMap<>();

  // passenger destination (should contain all passengers)
  public Map <Passenger, Station> passDestination = new HashMap<>();

  // who is onboard each train
  public Map <Train, Set<Passenger>> onboard = new HashMap<>();

  // who is waiting at each station
  public Map <Station, Set<Passenger>> waiting = new HashMap<>();

  // station states
  public Map <Station, StationState> stationStates = new HashMap<>();


  // Creates an initially empty simulation
  public MBTA() {}

  // Adds a new transit line with given name and stations
  public void addLine(String name, List<String> stations) {
    lines.put(name, stations);

    Train train = Train.make(name);
    List<Station> list = new ArrayList<>();
    for (String sname : stations) list.add(Station.make(sname));

    lineObj.put(train, list);
    trainLocation.put(train, list.get(0));
    if (TrainsAtStation.containsKey(list.get(0))) {
        TrainsAtStation.get(list.get(0)).add(train);
    } else {
        Set <Train> set = new HashSet<>();
        set.add(train);
        TrainsAtStation.put(list.get(0), set);
    }
    
  }

  // Adds a new planned journey to the simulation
  public void addJourney(String name, List<String> stations) {
    trips.put(name, stations);

    Passenger p = Passenger.make(name);
    List<Station> list = new ArrayList<>();
    for (String sname : stations) list.add(Station.make(sname));

    tripObj.put(p, list);

    passLocation.put(p, list.get(0));
    passDestination.put(p, list.get(list.size() - 1));

        
    // put the passenger at the wating queue
    if (waiting.containsKey(list.get(0))) {
      waiting.get(list.get(0)).add(p);
    } else {
      Set <Passenger> pass = new HashSet<>();
      pass.add(p);
      waiting.put(list.get(0), pass);
    }
  }
  

  // Return normally if initial simulation conditions are satisfied, otherwise
  // raises an exception
  public void checkStart() {
    // every train must be placed at first station of its line
    for (Map.Entry<Train, List<Station>> e : lineObj.entrySet()) {
      Train t = e.getKey();
      List<Station> stationList = e.getValue();
      if (stationList.isEmpty()) {
        throw new IllegalStateException();
      }
      Station expected = stationList.get(0);
      Station actual = trainLocation.get(t);

      if (actual == null) {
        throw new IllegalStateException();
      }
      if (!actual.equals(expected)) {
        throw new IllegalStateException();
      }
    }

    // passengers must start at the first station of their journey
    for (Map.Entry<Passenger, Station> e : passLocation.entrySet()) {
      Passenger p = e.getKey();
      Station acutalStart = e.getValue();
      boolean waitinghere = waiting.getOrDefault(acutalStart, Collections.emptySet()).contains(p);
      if (!waitinghere) {
        throw new IllegalStateException();
      }
    }

    // at most one train per station
    Map<Station, Integer> trainAtStation = new HashMap<>();
    for (Station s : trainLocation.values()) {
      trainAtStation.put(s, trainAtStation.getOrDefault(s, 0) + 1);
      if (trainAtStation.get(s) > 1) { 
        throw new IllegalStateException();
      }
    }

    // no passenger is onboard and waiting
    for (Passenger p : passLocation.keySet()) {
      boolean inWaiting = waiting.values().stream().anyMatch(set -> set.contains(p));
      boolean inOnboard = onboard.values().stream().anyMatch(set -> set.contains(p));
      if (inWaiting && inOnboard) {
        throw new IllegalStateException("Passenger " + p + " is both waiting and onboard at start");
      }
    }
  }

  // Return normally if final simulation conditions are satisfied, otherwise
  // raises an exception
  public void checkEnd() {
  // 1) Collision check using TrainsAtStation
  for (Map.Entry<Station, Set<Train>> e : TrainsAtStation.entrySet()) {
    Station s = e.getKey();
    Set<Train> trains = e.getValue();
    if (trains != null && trains.size() > 1) {
      throw new IllegalStateException("Collision: multiple trains at station " + s + ": " + trains);
    }
  }

  // 2) trainLocation <-> TrainsAtStation consistency and no two trains at same station
  Map<Station, Integer> trainCount = new HashMap<>();
  for (Map.Entry<Train, Station> e : trainLocation.entrySet()) {
    Train tr = e.getKey();
    Station loc = e.getValue();
    if (loc == null) {
      throw new IllegalStateException("Train " + tr + " has unknown location at end");
    }
    trainCount.put(loc, trainCount.getOrDefault(loc, 0) + 1);

    // ensure TrainsAtStation knows about this train
    Set<Train> setAt = TrainsAtStation.get(loc);
    if (setAt == null || !setAt.contains(tr)) {
      throw new IllegalStateException("Inconsistent state: train " + tr + " recorded at " + loc +
                                      " in trainLocation but missing from TrainsAtStation");
    }
  }
  for (Map.Entry<Station, Integer> e : trainCount.entrySet()) {
    if (e.getValue() > 1) {
      throw new IllegalStateException("Collision detected via trainLocation: multiple trains at " + e.getKey());
    }
  }

  // 3) stationStates consistency (if stationStates is being used)
  for (Map.Entry<Station, StationState> e : stationStates.entrySet()) {
    Station s = e.getKey();
    StationState st = e.getValue();
    if (st == null) continue;
    Train cur = st.currentTrain;
    if (cur != null) {
      Station loc = trainLocation.get(cur);
      if (loc == null || !loc.equals(s)) {
        throw new IllegalStateException("Inconsistent stationStates: stationStates[" + s + "].currentTrain = "
                                        + cur + " but trainLocation says " + loc);
      }
      Set<Train> setAt = TrainsAtStation.get(s);
      if (setAt == null || !setAt.contains(cur)) {
        throw new IllegalStateException("Inconsistent state: stationStates says " + cur + " at " + s +
                                        " but TrainsAtStation does not");
      }
    }
  }

  // 4) passenger final checks (not onboard and at destination and present in waiting set)
  for (Map.Entry<Passenger, Station> e : passDestination.entrySet()) {
    Passenger p = e.getKey();
    Station dest = e.getValue();

    // ensure not onboard any train
    boolean onboardAny = onboard.values().stream().anyMatch(set -> set.contains(p));
    if (onboardAny) {
      throw new IllegalStateException("Passenger " + p + " still onboard at end of simulation");
    }

    // ensure located at destination
    Station loc = passLocation.get(p);
    if (loc == null || !loc.equals(dest)) {
      String where = (loc == null) ? "unknown" : loc.toString();
      throw new IllegalStateException("Passenger " + p + " at " + where + " but expected at " + dest);
    }

    // ensure passenger is present in waiting[dest]
    Set<Passenger> waitingSet = waiting.getOrDefault(dest, Collections.emptySet());
    if (!waitingSet.contains(p)) {
      throw new IllegalStateException("Passenger " + p + " not present in waiting set at destination " + dest);
    }
  }
  }

  // reset to an empty simulation
  public void reset() {
    // throw new UnsupportedOperationException();
    lines.clear();
    trips.clear();

    lineObj.clear();
    trainLocation.clear();
    passDestination.clear();
    passLocation.clear();
    onboard.clear();
    waiting.clear();
    stationStates.clear();   // <- add this

  }

  // adds simulation configuration from a file
  public void loadConfig(String filename) {
    // throw new UnsupportedOperationException();
    // read in file as a string
    File myObj = new File(filename);
    String data = "";
    try (Scanner myReader = new Scanner(myObj)) {
      while (myReader.hasNextLine()) {
        data += myReader.nextLine();
      }
    } catch (FileNotFoundException e) {
      e.printStackTrace();
    }
    // System.out.println(data);

    Gson gson = new Gson();

    Config config = gson.fromJson(data, Config.class);
    if (config == null) {
        throw new IllegalStateException("input not formatted correctly");
    }

    reset();
    if (config.lines == null || config.trips == null) {
        throw new IllegalStateException("input not formatted correctly");
    }

    if (config.lines != null) {
      for (Map.Entry<String, List<String>> entry : config.lines.entrySet()) {
        addLine(entry.getKey(), entry.getValue());
      }
    }
    if (config.trips != null) {
      for (Map.Entry<String, List<String>> entry : config.trips.entrySet()) {
        addJourney(entry.getKey(), entry.getValue());
      }
    }
    // System.out.println(mbta.lines);
    // System.out.println(mbta.trips);
    // System.out.println(mbta.lines.size());

    initRuntimeState();
  }

  private static class Config {
    public Map<String, List<String>> lines;
    public Map<String, List<String>> trips;
  }

  public boolean passengersActive() {
    for (Map.Entry<Passenger, Station> e : passDestination.entrySet()) {
        Passenger p = e.getKey();
        Station dest = e.getValue();
        Station loc = passLocation.get(p);
        // If passenger is onboard (loc == null) or not at destination
        if (loc == null || !loc.equals(dest)) {
            return true;
        }
    }
    return false;
}


    // --- small helper class used by the simulator threads ---
  public static class StationState {
    public final Station station;
    public final ReentrantLock lock = new ReentrantLock();
    public final Condition changed = lock.newCondition();
    // which train currently occupies the station (null if empty)
    public Train currentTrain = null;

    public StationState(Station station) {
      this.station = station;
    }

    @Override
    public String toString() {
      return "StationState(" + station + ", train=" + currentTrain + ")";
    }
  }

  // --- initialize runtime state that threads expect ---
  // Call this *after* you built lineObj and tripObj (i.e., at end of loadConfig)
  public void initRuntimeState() {
    stationStates = new HashMap<>();
    trainLocation = new HashMap<>();
    onboard = new HashMap<>();
    waiting = new HashMap<>();

    // stations from lines
    for (List<Station> stations : lineObj.values()) {
        for (Station s : stations) {
            stationStates.putIfAbsent(s, new StationState(s));
            waiting.putIfAbsent(s, new HashSet<>());
        }
    }

    // also include stations from trips
    for (List<Station> trip : tripObj.values()) {
        for (Station s : trip) {
            stationStates.putIfAbsent(s, new StationState(s));
            waiting.putIfAbsent(s, new HashSet<>());
        }
    }

    // initialize trains
    for (Map.Entry<Train, List<Station>> e : lineObj.entrySet()) {
        Train t = e.getKey();
        Station start = e.getValue().get(0);

        trainLocation.put(t, start);
        onboard.put(t, new HashSet<>());
        stationStates.get(start).currentTrain = t;
    }

    // initialize passengers
    passDestination = new HashMap<>();
    for (Map.Entry<Passenger, List<Station>> e : tripObj.entrySet()) {
        Passenger p = e.getKey();
        List<Station> trip = e.getValue();

        Station start = trip.get(0);
        Station dest = trip.get(trip.size() - 1);

        passLocation.put(p, start);
        passDestination.put(p, dest);

        waiting.get(start).add(p);
    }
  }
}
