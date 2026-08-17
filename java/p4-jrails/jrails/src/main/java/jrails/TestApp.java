package jrails;

public class TestApp {
        public static void main(String[] args) {
                System.out.println("Running DB test...");

                Model.reset(); // clear DB

        // // Create example model subclass
        // User u = new User();
        // u.name = "Bob";
        // u.age = 19;
        // u.save(); // should create DB + table + insert

        // System.out.println("Saved user with id = " + u.id());

        // // Update it
        // u.age = 20;
        // u.save(); // should update instead of inserting
    }
}
