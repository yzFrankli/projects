import java.util.HashMap;

public class Station extends Entity {
  private static HashMap<String, Station> stations = new HashMap<>();

  private Station(String name) { super(name); }

  public static Station make(String name) {
    // Change this method!
    if (stations.get(name) == null) {
      Station newStation = new Station(name);
      stations.put(name, newStation);
      return newStation;
    } else {
      return stations.get(name);
    }
  }
}
