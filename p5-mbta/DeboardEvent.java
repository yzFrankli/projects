import java.util.*;

public class DeboardEvent implements Event {
  public final Passenger p; public final Train t; public final Station s;
  public DeboardEvent(Passenger p, Train t, Station s) {
    this.p = p; this.t = t; this.s = s;
  }
  public boolean equals(Object o) {
    if (o instanceof DeboardEvent e) {
      return p.equals(e.p) && t.equals(e.t) && s.equals(e.s);
    }
    return false;
  }
  public int hashCode() {
    return Objects.hash(p, t, s);
  }
  public String toString() {
    return "Passenger " + p + " deboards " + t + " at " + s;
  }
  public List<String> toStringList() {
    return List.of(p.toString(), t.toString(), s.toString());
  }
  public void replayAndCheck(MBTA mbta) {
  // 1) train must exist in trainLocation
  if (!mbta.trainLocation.containsKey(t)) {
    throw new IllegalStateException("Unknown train: " + t);
  }

  // 2) train must be at station s
  Station trainLoc = mbta.trainLocation.get(t);
  if (trainLoc == null || !trainLoc.equals(s)) {
    throw new IllegalStateException("Train " + t + " not at station " + s + " (at " + trainLoc + ")");
  }

  // 3) passenger must be known
  if (!mbta.passLocation.containsKey(p)) {
    throw new IllegalStateException("Unknown passenger: " + p);
  }

  // 4) passenger must currently be onboard (passLocation == null)
  Station pLoc = mbta.passLocation.get(p);
  if (pLoc != null) {
    throw new IllegalStateException("Passenger " + p + " not onboard (at " + pLoc + ")");
  }

  // 5) passenger must actually be onboard this train
  Set<Passenger> onboardSet = mbta.onboard.get(t);
  if (onboardSet == null || !onboardSet.contains(p)) {
    throw new IllegalStateException("Passenger " + p + " not recorded onboard train " + t);
  }

  // 6) ensure waiting set exists for station s (create if missing)
  Set<Passenger> waitSet = mbta.waiting.computeIfAbsent(s, k -> new HashSet<>());

  // 7) perform the deboard: remove from onboard, set passLocation, add to waiting
  onboardSet.remove(p);
  mbta.passLocation.put(p, s);
  waitSet.add(p);

  // optional: debug
  System.err.println("Deboarded passenger " + p + " from " + t + " at " + s);


  }
}
