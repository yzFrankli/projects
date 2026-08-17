import java.util.HashMap;

public class Passenger extends Entity {
  private static HashMap<String, Passenger> passengers = new HashMap<>();

  private Passenger(String name) { super(name); }

  public static Passenger make(String name) {
    // Change this method!
    if (passengers.get(name) == null) {
      Passenger newPass = new Passenger(name);
      passengers.put(name, newPass);
      return newPass;
    } else {
      return passengers.get(name);
    }
  }
}
