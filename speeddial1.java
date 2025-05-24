import java.util.HashMap;
import java.util.Map;
import java.util.Scanner;

/**
 * A simple SpeedDial system that maps integer numbers to contact names/details.
 * It uses a HashMap to store the speed dial entries.
 */
public class SpeedDial {

    // HashMap to store speed dial entries: Integer (speed dial number) -> String (contact name/details)
    private Map<Integer, String> speedDialEntries;

    /**
     * Constructor to initialize the SpeedDial system.
     */
    public SpeedDial() {
        this.speedDialEntries = new HashMap<>();
        System.out.println("Speed Dial system initialized.");
    }

    /**
     * Adds a new entry to the speed dial.
     * If the speed dial number already exists, it updates the contact.
     *
     * @param speedDialNumber The integer number for the speed dial.
     * @param contactDetails  The name or details of the contact.
     */
    public void addEntry(int speedDialNumber, String contactDetails) {
        if (speedDialNumber <= 0) {
            System.out.println("Error: Speed dial number must be positive.");
            return;
        }
        speedDialEntries.put(speedDialNumber, contactDetails);
        System.out.println("Added/Updated speed dial " + speedDialNumber + ": " + contactDetails);
    }

    /**
     * Retrieves the contact details associated with a given speed dial number.
     *
     * @param speedDialNumber The speed dial number to look up.
     * @return The contact details if found, otherwise "Contact not found."
     */
    public String getContact(int speedDialNumber) {
        if (speedDialEntries.containsKey(speedDialNumber)) {
            return speedDialEntries.get(speedDialNumber);
        } else {
            return "Contact not found for speed dial " + speedDialNumber + ".";
        }
    }

    /**
     * Removes an entry from the speed dial.
     *
     * @param speedDialNumber The speed dial number of the entry to remove.
     */
    public void removeEntry(int speedDialNumber) {
        if (speedDialEntries.containsKey(speedDialNumber)) {
            String removedContact = speedDialEntries.remove(speedDialNumber);
            System.out.println("Removed speed dial " + speedDialNumber + ": " + removedContact);
        } else {
            System.out.println("Speed dial " + speedDialNumber + " does not exist.");
        }
    }

    /**
     * Displays all current speed dial entries.
     */
    public void listEntries() {
        if (speedDialEntries.isEmpty()) {
            System.out.println("No speed dial entries found.");
            return;
        }
        System.out.println("\n--- Current Speed Dial Entries ---");
        // Iterate through the HashMap and print each entry
        for (Map.Entry<Integer, String> entry : speedDialEntries.entrySet()) {
            System.out.println("Speed Dial " + entry.getKey() + ": " + entry.getValue());
        }
        System.out.println("----------------------------------\n");
    }

    /**
     * Main method to demonstrate the SpeedDial system.
     * It provides a simple command-line interface for interaction.
     */
    public static void main(String[] args) {
        SpeedDial mySpeedDial = new SpeedDial();
        Scanner scanner = new Scanner(System.in);
        boolean running = true;

        System.out.println("Welcome to the Java Speed Dial Application!");
        System.out.println("Type 'help' for commands.");

        while (running) {
            System.out.print("Enter command (add, get, remove, list, help, exit): ");
            String command = scanner.nextLine().trim().toLowerCase();

            switch (command) {
                case "add":
                    try {
                        System.out.print("Enter speed dial number: ");
                        int numToAdd = Integer.parseInt(scanner.nextLine());
                        System.out.print("Enter contact details (e.g., John Doe - 123-456-7890): ");
                        String contactToAdd = scanner.nextLine();
                        mySpeedDial.addEntry(numToAdd, contactToAdd);
                    } catch (NumberFormatException e) {
                        System.out.println("Invalid number format. Please enter an integer.");
                    }
                    break;
                case "get":
                    try {
                        System.out.print("Enter speed dial number to retrieve: ");
                        int numToGet = Integer.parseInt(scanner.nextLine());
                        System.out.println("Result: " + mySpeedDial.getContact(numToGet));
                    } catch (NumberFormatException e) {
                        System.out.println("Invalid number format. Please enter an integer.");
                    }
                    break;
                case "remove":
                    try {
                        System.out.print("Enter speed dial number to remove: ");
                        int numToRemove = Integer.parseInt(scanner.nextLine());
                        mySpeedDial.removeEntry(numToRemove);
                    } catch (NumberFormatException e) {
                        System.out.println("Invalid number format. Please enter an integer.");
                    }
                    break;
                case "list":
                    mySpeedDial.listEntries();
                    break;
                case "help":
                    System.out.println("\n--- Commands ---");
                    System.out.println("add    : Add a new speed dial entry or update an existing one.");
                    System.out.println("get    : Retrieve contact details using a speed dial number.");
                    System.out.println("remove : Remove a speed dial entry.");
                    System.out.println("list   : Display all current speed dial entries.");
                    System.out.println("help   : Show this help message.");
                    System.out.println("exit   : Exit the application.");
                    System.out.println("------------------\n");
                    break;
                case "exit":
                    running = false;
                    System.out.println("Exiting Speed Dial application. Goodbye!");
                    break;
                default:
                    System.out.println("Unknown command. Type 'help' for available commands.");
                    break;
            }
        }
        scanner.close(); // Close the scanner to prevent resource leaks
    }
}
