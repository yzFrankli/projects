import java.util.*;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.ReentrantLock;

public class BoardEvent implements Event {
  public final Passenger p; public final Train t; public final Station s;
  public BoardEvent(Passenger p, Train t, Station s) {
    this.p = p; this.t = t; this.s = s;
  }
  public boolean equals(Object o) {
    if (o instanceof BoardEvent e) {
      return p.equals(e.p) && t.equals(e.t) && s.equals(e.s);
    }
    return false;
  }
  public int hashCode() {
    return Objects.hash(p, t, s);
  }
  public String toString() {
    return "Passenger " + p + " boards " + t + " at " + s;
  }
  public List<String> toStringList() {
    return List.of(p.toString(), t.toString(), s.toString());
  }
  public void replayAndCheck(MBTA mbta) {

    // 1. train exists and located at s
    if (!mbta.trainLocation.containsKey(t)) {
        throw new IllegalStateException("Unknown train");
    }
    if (!mbta.trainLocation.get(t).equals(s)) {
        throw new IllegalStateException("Train not at station");
    }

    // 2. passenger exists and is waiting at s
    if (!mbta.passLocation.containsKey(p)) {
        throw new IllegalStateException("Unknown passenger");
    }

    if (!s.equals(mbta.passLocation.get(p))) {
        throw new IllegalStateException("Passenger not at station");
    }

    Set<Passenger> waitSet = mbta.waiting.get(s);
    if (waitSet == null || !waitSet.contains(p)) {
        throw new IllegalStateException("Passenger not waiting");
    }

    // 3. ensure passenger is not onboard any other train
    for (Set<Passenger> set : mbta.onboard.values()) {
        if (set.contains(p)) {
            throw new IllegalStateException("Passenger already onboard");
        }
    }

    // DO NOT MODIFY waiting, onboard, or passLocation
    mbta.passLocation.replace(p, null);
    try {
        mbta.waiting.get(s).remove(p);
    } catch (NullPointerException e) {

    }
    
    mbta.onboard.get(t).add(p);
  }
}
