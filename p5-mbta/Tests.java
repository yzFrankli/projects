import static org.junit.Assert.*;
import java.util.*;

import java.util.ArrayList;

import org.junit.*;

public class Tests {
  @Test public void testPass() {
    System.err.println("running test!");
    assertTrue("true should be true", true);
  }

  @Test public void testMoveEvent() {
    System.err.println("running test2!");
    MBTA mbta = new MBTA();

    List<String> testLine = new ArrayList<>();
    testLine.add("Davis");
    testLine.add("Tufts");
    testLine.add("Harvard");

    List<Station> testStations = new ArrayList<>();
    Station Davis = Station.make(testLine.get(0)); // make Davis station
    Station Tufts = Station.make(testLine.get(1)); // make Tufts station
    Station Harvard = Station.make(testLine.get(2)); // make Harvard station
    // add to stations
    testStations.add(Davis);
    testStations.add(Tufts);
    testStations.add(Harvard);

    // make passenger
    Passenger pass = Passenger.make("Pass1");

    // add to journey
    List<String> journey = new ArrayList<>();
    journey.add(testLine.get(1));
    journey.add(testLine.get(2));

    // add to mbta class
    mbta.addLine("Green", testLine);
    Train testTrain = Train.make("Green");
    mbta.addJourney("Pass1", journey);


    // log events
    Log log = new Log();
    log.train_moves(testTrain, Davis, Tufts); // train moves 1 station
    log.passenger_boards(pass, testTrain, Tufts); // passenger board at tufts
    log.train_moves(testTrain, Tufts, Harvard);
    log.passenger_deboards(pass, testTrain, Harvard); // deboard at harvard

    // verify if log is correct
    Verify.verify(mbta, log);


    // assertTrue()
  }

  @Test public void testMBTA() {
    MBTA mbta = new MBTA();
    System.out.println("Testing mbta config");
    mbta.loadConfig("sample.json");
  }

  @Test public void testConfig() {
    MBTA mbta = new MBTA();
    mbta.loadConfig("sample.json");
    System.out.println("num of lines: " + mbta.lineObj.size());
    System.out.println("num of pass: " + mbta.tripObj.size());
  }
}
