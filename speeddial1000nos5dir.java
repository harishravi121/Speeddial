import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

/**
 * Implements a speed dial system with a fixed number of directories and a maximum
 * capacity for phone numbers within each directory.
 */
public class SpeedDialManager {

    // Defines the maximum number of directories allowed in the system.
    private static final int MAX_DIRECTORIES = 5;
    // Defines the maximum number of speed dial entries allowed per directory.
    // Calculated as total numbers (1000) / number of directories (5).
    private static final int MAX_NUMBERS_PER_DIRECTORY = 1000 / MAX_DIRECTORIES;

    // A map to store the directories.
    // Key: Directory name (String)
    // Value: Another map representing the speed dial entries within that directory.
    //        Inner Map Key: Speed dial code (String, e.g., "home", "work", "1")
    //        Inner Map Value: Phone number (String)
    private Map<String, Map<String, String>> directories;

    /**
     * Constructs a new SpeedDialManager and initializes the predefined number of directories.
     * Each directory is created as an empty HashMap ready to store speed dial entries.
     */
    public SpeedDialManager() {
        this.directories = new HashMap<>();
        // Initialize the specified number of directories with default names.
        for (int i = 1; i <= MAX_DIRECTORIES; i++) {
            directories.put("Directory " + i, new HashMap<>());
        }
        System.out.println("SpeedDialManager initialized with " + MAX_DIRECTORIES + " directories.");
    }

    /**
     * Adds a phone number to a specified speed dial directory.
     *
     * @param directoryName   The name of the directory (e.g., "Directory 1") where the number should be added.
     * @param speedDialCode   The unique code (e.g., "home", "work", "123") used to quickly dial the number.
     * @param phoneNumber     The actual phone number to store.
     * @return true if the number was added successfully; false if the directory does not exist,
     * the directory is full, or the speed dial code already exists within that directory.
     */
    public boolean addNumber(String directoryName, String speedDialCode, String phoneNumber) {
        // Check if the specified directory exists.
        if (!directories.containsKey(directoryName)) {
            System.out.println("Error: Directory '" + directoryName + "' does not exist. Cannot add number.");
            return false;
        }

        Map<String, String> directory = directories.get(directoryName);

        // Check if the directory has reached its maximum capacity.
        if (directory.size() >= MAX_NUMBERS_PER_DIRECTORY) {
            System.out.println("Error: Directory '" + directoryName + "' is full. Max " + MAX_NUMBERS_PER_DIRECTORY + " numbers allowed. Cannot add number.");
            return false;
        }

        // Check if the speed dial code already exists in this directory.
        if (directory.containsKey(speedDialCode)) {
            System.out.println("Error: Speed dial code '" + speedDialCode + "' already exists in '" + directoryName + "'. Cannot add duplicate.");
            return false;
        }

        // Add the new speed dial entry to the directory.
        directory.put(speedDialCode, phoneNumber);
        System.out.println("Successfully added '" + speedDialCode + "' -> '" + phoneNumber + "' to '" + directoryName + "'.");
        return true;
    }

    /**
     * Retrieves a phone number from a specified speed dial directory using its speed dial code.
     *
     * @param directoryName   The name of the directory to search within.
     * @param speedDialCode   The speed dial code associated with the desired phone number.
     * @return The phone number as a String if found; null if the directory does not exist
     * or the speed dial code is not found within the directory.
     */
    public String getPhoneNumber(String directoryName, String speedDialCode) {
        // Check if the specified directory exists.
        if (!directories.containsKey(directoryName)) {
            System.out.println("Error: Directory '" + directoryName + "' does not exist. Cannot retrieve number.");
            return null;
        }

        // Retrieve the phone number using the speed dial code.
        String phoneNumber = directories.get(directoryName).get(speedDialCode);

        if (phoneNumber == null) {
            System.out.println("Phone number for speed dial code '" + speedDialCode + "' not found in '" + directoryName + "'.");
        } else {
            System.out.println("Retrieved '" + speedDialCode + "' from '" + directoryName + "': " + phoneNumber);
        }
        return phoneNumber;
    }

    /**
     * Removes a speed dial entry from a specified directory.
     *
     * @param directoryName   The name of the directory from which to remove the entry.
     * @param speedDialCode   The speed dial code of the entry to be removed.
     * @return true if the entry was successfully removed; false if the directory does not exist
     * or the speed dial code was not found in the directory.
     */
    public boolean removeNumber(String directoryName, String speedDialCode) {
        // Check if the specified directory exists.
        if (!directories.containsKey(directoryName)) {
            System.out.println("Error: Directory '" + directoryName + "' does not exist. Cannot remove number.");
            return false;
        }

        Map<String, String> directory = directories.get(directoryName);

        // Check if the speed dial code exists in the directory before attempting to remove.
        if (directory.containsKey(speedDialCode)) {
            String removedNumber = directory.remove(speedDialCode);
            System.out.println("Successfully removed '" + speedDialCode + "' -> '" + removedNumber + "' from '" + directoryName + "'.");
            return true;
        } else {
            System.out.println("Speed dial code '" + speedDialCode + "' not found in '" + directoryName + "'. No number removed.");
            return false;
        }
    }

    /**
     * Lists all speed dial entries (codes and numbers) in a given directory.
     *
     * @param directoryName The name of the directory to list entries from.
     * @return An unmodifiable map of speed dial codes to phone numbers in the specified directory.
     * Returns an empty map if the directory does not exist or is empty.
     */
    public Map<String, String> listNumbersInDirectory(String directoryName) {
        // Check if the specified directory exists.
        if (!directories.containsKey(directoryName)) {
            System.out.println("Error: Directory '" + directoryName + "' does not exist. Cannot list numbers.");
            return Collections.emptyMap(); // Return an empty map if directory not found
        }

        Map<String, String> directory = directories.get(directoryName);

        System.out.println("\n--- Listing numbers in '" + directoryName + "' (" + directory.size() + "/" + MAX_NUMBERS_PER_DIRECTORY + ") ---");
        if (directory.isEmpty()) {
            System.out.println("  Directory is empty.");
        } else {
            directory.forEach((code, number) -> System.out.println("  " + code + ": " + number));
        }
        // Return an unmodifiable view of the directory to prevent external modification.
        return Collections.unmodifiableMap(directory);
    }

    /**
     * Returns a set of all directory names currently managed by this speed dial manager.
     *
     * @return An unmodifiable set containing the names of all directories.
     */
    public Set<String> getAllDirectoryNames() {
        return Collections.unmodifiableSet(directories.keySet());
    }

    /**
     * Main method for demonstrating the SpeedDialManager functionality.
     * It initializes the manager, adds, retrieves, removes, and lists numbers,
     * showcasing various use cases and error conditions.
     */
    public static void main(String[] args) {
        System.out.println("--- Starting Speed Dial System Demonstration ---");

        // 1. Initialize the SpeedDialManager
        SpeedDialManager manager = new SpeedDialManager();

        // 2. List all initial directories
        System.out.println("\n--- All available directories ---");
        manager.getAllDirectoryNames().forEach(System.out::println);

        // 3. Add some sample numbers to different directories
        System.out.println("\n--- Adding sample numbers ---");
        manager.addNumber("Directory 1", "home", "123-456-7890");
        manager.addNumber("Directory 1", "work", "987-654-3210");
        manager.addNumber("Directory 1", "mom", "555-111-2222");
        manager.addNumber("Directory 2", "friend1", "111-222-3333");
        manager.addNumber("Directory 2", "friend2", "444-555-6666");
        manager.addNumber("Directory 5", "emergency", "911");

        // 4. Demonstrate error cases for adding numbers
        System.out.println("\n--- Demonstrating add number error cases ---");
        // Try adding to a non-existent directory
        manager.addNumber("Directory 6", "test", "000-000-0000");
        // Try adding a duplicate speed dial code in the same directory
        manager.addNumber("Directory 1", "home", "123-999-8888");

        // 5. Demonstrate directory capacity limit
        System.out.println("\n--- Demonstrating directory capacity limit (filling Directory 3) ---");
        // Fill Directory 3 almost to its limit
        for (int i = 0; i < MAX_NUMBERS_PER_DIRECTORY - 1; i++) {
            manager.addNumber("Directory 3", "contact" + i, "000-000-" + String.format("%04d", i));
        }
        // Try to add one more number to a full directory
        manager.addNumber("Directory 3", "overflow", "999-999-9999");
        manager.listNumbersInDirectory("Directory 3"); // Show the full directory

        // 6. Retrieve numbers
        System.out.println("\n--- Retrieving numbers ---");
        String momNumber = manager.getPhoneNumber("Directory 1", "mom");
        String friend2Number = manager.getPhoneNumber("Directory 2", "friend2");
        String nonExistentNumber = manager.getPhoneNumber("Directory 1", "dad"); // Not found
        String nonExistentDirNumber = manager.getPhoneNumber("Directory 7", "any"); // Directory not found

        // 7. List numbers in specific directories
        manager.listNumbersInDirectory("Directory 1");
        manager.listNumbersInDirectory("Directory 2");
        manager.listNumbersInDirectory("Directory 4"); // This directory should be empty

        // 8. Remove numbers
        System.out.println("\n--- Removing numbers ---");
        manager.removeNumber("Directory 1", "work"); // Successful removal
        manager.removeNumber("Directory 2", "nonexistent"); // Try removing a non-existent entry
        manager.removeNumber("Directory 6", "any"); // Try removing from a non-existent directory

        // 9. List numbers after removal
        manager.listNumbersInDirectory("Directory 1");

        System.out.println("\n--- Speed Dial System Demonstration Complete ---");
    }
}
