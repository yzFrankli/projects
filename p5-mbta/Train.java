import java.util.HashMap;

public class Train extends Entity {
  private static HashMap<String, Train> trains = new HashMap<>();

  // constructor
  private Train(String name) { super(name); }

  // return instances of the Train class
  // if called multiple times with the same name, return the same instance
  public static Train make(String name) {
    // Change this method!
    if (trains.get(name) == null) { // no instance exist
      Train newTrain = new Train(name);
      trains.put(name, newTrain);
      return newTrain;
    } else {
      return trains.get(name);
    }
  }
}
