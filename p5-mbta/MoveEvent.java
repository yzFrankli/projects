import java.util.*;

public class MoveEvent implements Event {
  public final Train t; public final Station s1, s2;
  public MoveEvent(Train t, Station s1, Station s2) {
    this.t = t; this.s1 = s1; this.s2 = s2;
  }
  public boolean equals(Object o) {
    if (o instanceof MoveEvent e) {
      return t.equals(e.t) && s1.equals(e.s1) && s2.equals(e.s2);
    }
    return false;
  }
  public int hashCode() {
    return Objects.hash(t, s1, s2);
  }
  public String toString() {
    return "Train " + t + " moves from " + s1 + " to " + s2;
  }
  public List<String> toStringList() {
    return List.of(t.toString(), s1.toString(), s2.toString());
  }
  public void replayAndCheck(MBTA mbta) {
    // 1. train exists
    if (!mbta.lineObj.containsKey(t))
        throw new IllegalStateException("Unknown train: " + t);

    // 2. train must currently be at s1
    Station loc = mbta.trainLocation.get(t);
    if (loc == null || !loc.equals(s1))
        throw new IllegalStateException("Train " + t + " not at source " + s1);

    // 3. adjacency check
    List<Station> line = mbta.lineObj.get(t);
    int idx = line.indexOf(s1);
    if (idx == -1) throw new IllegalStateException("Line does not contain station " + s1);

    boolean adjacent =
        (idx > 0 && line.get(idx - 1).equals(s2)) ||
        (idx < line.size() - 1 && line.get(idx + 1).equals(s2));

    if (!adjacent)
        throw new IllegalStateException("Stations " + s1 + " and " + s2 + " not adjacent");

    // --- 4. COLLISION CHECK using stationStates (authoritative source) ---
    MBTA.StationState destState = mbta.stationStates.get(s2);
    MBTA.StationState srcState = mbta.stationStates.get(s1);

    if (destState == null || srcState == null)
        throw new IllegalStateException("Missing stationState");

    Train occ = destState.currentTrain;
    if (occ != null && !occ.equals(t)) {
        throw new IllegalStateException(
            "Collision: " + t + " attempted to enter " + s2 +
            " but occupied by " + occ
        );
    }

    // --- 5. UPDATE AUTHORITATIVE STATE (must be consistent!) ---
    // s1 becomes empty
    srcState.currentTrain = null;

    // s2 now has train t
    destState.currentTrain = t;

    // trainLocation must also update
    mbta.trainLocation.put(t, s2);

    // (Optional) keep your TrainsAtStation map consistent if teacher uses it
    mbta.TrainsAtStation.getOrDefault(s1, Collections.emptySet()).remove(t);
    mbta.TrainsAtStation.putIfAbsent(s2, new HashSet<>());
    mbta.TrainsAtStation.get(s2).add(t);
  }
}
