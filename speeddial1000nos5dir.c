#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h> // For true/false

// --- Constants ---
#define MAX_DIRECTORIES 5
#define TOTAL_NUMBERS 1000
#define MAX_NUMBERS_PER_DIRECTORY (TOTAL_NUMBERS / MAX_DIRECTORIES) // 200 numbers per directory

#define MAX_CODE_LENGTH 50    // Max length for speed dial code (e.g., "home", "work")
#define MAX_PHONE_LENGTH 20   // Max length for phone number (e.g., "123-456-7890")
#define MAX_DIR_NAME_LENGTH 50 // Max length for directory name (e.g., "Directory 1")

// --- Data Structures ---

/**
 * @brief Represents a single speed dial entry.
 * Stores a unique speed dial code and its corresponding phone number.
 */
typedef struct {
    char speedDialCode[MAX_CODE_LENGTH];
    char phoneNumber[MAX_PHONE_LENGTH];
} SpeedDialEntry;

/**
 * @brief Represents a single directory within the speed dial system.
 * Contains a name, a dynamic array of speed dial entries, and the current count of entries.
 */
typedef struct {
    char name[MAX_DIR_NAME_LENGTH];
    SpeedDialEntry *entries; // Pointer to a dynamically allocated array of SpeedDialEntry
    int currentCount;        // Current number of entries in this directory
} Directory;

/**
 * @brief Manages the entire speed dial system.
 * Contains an array of Directory structs and a flag to indicate initialization status.
 */
typedef struct {
    Directory directories[MAX_DIRECTORIES];
    bool initialized; // Flag to indicate if the manager has been initialized
} SpeedDialManager;

// --- Global Manager Instance ---
// This makes the manager accessible throughout the program.
// For larger applications, it's often better to pass a pointer to the manager.
SpeedDialManager manager;

// --- Function Prototypes ---
void initializeSpeedDialManager();
bool addNumber(const char *directoryName, const char *speedDialCode, const char *phoneNumber);
const char *getPhoneNumber(const char *directoryName, const char *speedDialCode);
bool removeNumber(const char *directoryName, const char *speedDialCode);
void listNumbersInDirectory(const char *directoryName);
void listAllDirectoryNames();
void freeSpeedDialManager();

// --- Function Implementations ---

/**
 * @brief Initializes the SpeedDialManager.
 * Sets up the predefined number of directories and allocates initial memory for their entries.
 */
void initializeSpeedDialManager() {
    if (manager.initialized) {
        printf("SpeedDialManager already initialized.\n");
        return;
    }

    printf("Initializing SpeedDialManager with %d directories...\n", MAX_DIRECTORIES);
    for (int i = 0; i < MAX_DIRECTORIES; i++) {
        // Construct directory name (e.g., "Directory 1")
        snprintf(manager.directories[i].name, MAX_DIR_NAME_LENGTH, "Directory %d", i + 1);
        manager.directories[i].currentCount = 0;
        // Allocate initial memory for entries. We can realloc later if needed,
        // but allocating for MAX_NUMBERS_PER_DIRECTORY upfront simplifies things
        // for this fixed-capacity scenario.
        manager.directories[i].entries = (SpeedDialEntry *)malloc(MAX_NUMBERS_PER_DIRECTORY * sizeof(SpeedDialEntry));
        if (manager.directories[i].entries == NULL) {
            perror("Failed to allocate memory for directory entries");
            // Handle error: potentially free already allocated memory and exit
            freeSpeedDialManager(); // Clean up what was allocated so far
            exit(EXIT_FAILURE);
        }
    }
    manager.initialized = true;
    printf("SpeedDialManager initialized successfully.\n");
}

/**
 * @brief Adds a phone number to a specified speed dial directory.
 *
 * @param directoryName The name of the directory (e.g., "Directory 1") where the number should be added.
 * @param speedDialCode The unique code (e.g., "home", "work", "123") used to quickly dial the number.
 * @param phoneNumber The actual phone number to store.
 * @return true if the number was added successfully; false if the directory does not exist,
 * the directory is full, or the speed dial code already exists within that directory.
 */
bool addNumber(const char *directoryName, const char *speedDialCode, const char *phoneNumber) {
    if (!manager.initialized) {
        printf("Error: SpeedDialManager not initialized. Call initializeSpeedDialManager() first.\n");
        return false;
    }

    // Find the directory
    int dirIndex = -1;
    for (int i = 0; i < MAX_DIRECTORIES; i++) {
        if (strcmp(manager.directories[i].name, directoryName) == 0) {
            dirIndex = i;
            break;
        }
    }

    if (dirIndex == -1) {
        printf("Error: Directory '%s' does not exist. Cannot add number.\n", directoryName);
        return false;
    }

    Directory *dir = &manager.directories[dirIndex];

    // Check if the directory has reached its maximum capacity.
    if (dir->currentCount >= MAX_NUMBERS_PER_DIRECTORY) {
        printf("Error: Directory '%s' is full. Max %d numbers allowed. Cannot add number.\n", directoryName, MAX_NUMBERS_PER_DIRECTORY);
        return false;
    }

    // Check if the speed dial code already exists in this directory.
    for (int i = 0; i < dir->currentCount; i++) {
        if (strcmp(dir->entries[i].speedDialCode, speedDialCode) == 0) {
            printf("Error: Speed dial code '%s' already exists in '%s'. Cannot add duplicate.\n", speedDialCode, directoryName);
            return false;
        }
    }

    // Add the new speed dial entry
    strncpy(dir->entries[dir->currentCount].speedDialCode, speedDialCode, MAX_CODE_LENGTH - 1);
    dir->entries[dir->currentCount].speedDialCode[MAX_CODE_LENGTH - 1] = '\0'; // Ensure null-termination
    strncpy(dir->entries[dir->currentCount].phoneNumber, phoneNumber, MAX_PHONE_LENGTH - 1);
    dir->entries[dir->currentCount].phoneNumber[MAX_PHONE_LENGTH - 1] = '\0'; // Ensure null-termination

    dir->currentCount++;
    printf("Successfully added '%s' -> '%s' to '%s'.\n", speedDialCode, phoneNumber, directoryName);
    return true;
}

/**
 * @brief Retrieves a phone number from a specified speed dial directory using its speed dial code.
 *
 * @param directoryName The name of the directory to search within.
 * @param speedDialCode The speed dial code associated with the desired phone number.
 * @return The phone number as a const char* if found; NULL if the directory does not exist
 * or the speed dial code is not found within the directory.
 */
const char *getPhoneNumber(const char *directoryName, const char *speedDialCode) {
    if (!manager.initialized) {
        printf("Error: SpeedDialManager not initialized. Call initializeSpeedDialManager() first.\n");
        return NULL;
    }

    // Find the directory
    int dirIndex = -1;
    for (int i = 0; i < MAX_DIRECTORIES; i++) {
        if (strcmp(manager.directories[i].name, directoryName) == 0) {
            dirIndex = i;
            break;
        }
    }

    if (dirIndex == -1) {
        printf("Error: Directory '%s' does not exist. Cannot retrieve number.\n", directoryName);
        return NULL;
    }

    Directory *dir = &manager.directories[dirIndex];

    // Search for the speed dial code
    for (int i = 0; i < dir->currentCount; i++) {
        if (strcmp(dir->entries[i].speedDialCode, speedDialCode) == 0) {
            printf("Retrieved '%s' from '%s': %s\n", speedDialCode, directoryName, dir->entries[i].phoneNumber);
            return dir->entries[i].phoneNumber;
        }
    }

    printf("Phone number for speed dial code '%s' not found in '%s'.\n", speedDialCode, directoryName);
    return NULL;
}

/**
 * @brief Removes a speed dial entry from a specified directory.
 *
 * @param directoryName The name of the directory from which to remove the entry.
 * @param speedDialCode The speed dial code of the entry to be removed.
 * @return true if the entry was successfully removed; false if the directory does not exist
 * or the speed dial code was not found in the directory.
 */
bool removeNumber(const char *directoryName, const char *speedDialCode) {
    if (!manager.initialized) {
        printf("Error: SpeedDialManager not initialized. Call initializeSpeedDialManager() first.\n");
        return false;
    }

    // Find the directory
    int dirIndex = -1;
    for (int i = 0; i < MAX_DIRECTORIES; i++) {
        if (strcmp(manager.directories[i].name, directoryName) == 0) {
            dirIndex = i;
            break;
        }
    }

    if (dirIndex == -1) {
        printf("Error: Directory '%s' does not exist. Cannot remove number.\n", directoryName);
        return false;
    }

    Directory *dir = &manager.directories[dirIndex];

    // Find the entry to remove
    int entryIndex = -1;
    for (int i = 0; i < dir->currentCount; i++) {
        if (strcmp(dir->entries[i].speedDialCode, speedDialCode) == 0) {
            entryIndex = i;
            break;
        }
    }

    if (entryIndex == -1) {
        printf("Speed dial code '%s' not found in '%s'. No number removed.\n", speedDialCode, directoryName);
        return false;
    }

    // Shift elements to fill the gap created by removal
    printf("Successfully removed '%s' -> '%s' from '%s'.\n",
           dir->entries[entryIndex].speedDialCode, dir->entries[entryIndex].phoneNumber, directoryName);
    for (int i = entryIndex; i < dir->currentCount - 1; i++) {
        dir->entries[i] = dir->entries[i + 1];
    }
    dir->currentCount--; // Decrement the count of entries

    return true;
}

/**
 * @brief Lists all speed dial entries (codes and numbers) in a given directory.
 *
 * @param directoryName The name of the directory to list entries from.
 */
void listNumbersInDirectory(const char *directoryName) {
    if (!manager.initialized) {
        printf("Error: SpeedDialManager not initialized. Call initializeSpeedDialManager() first.\n");
        return;
    }

    // Find the directory
    int dirIndex = -1;
    for (int i = 0; i < MAX_DIRECTORIES; i++) {
        if (strcmp(manager.directories[i].name, directoryName) == 0) {
            dirIndex = i;
            break;
        }
    }

    if (dirIndex == -1) {
        printf("Error: Directory '%s' does not exist. Cannot list numbers.\n", directoryName);
        return;
    }

    Directory *dir = &manager.directories[dirIndex];

    printf("\n--- Listing numbers in '%s' (%d/%d) ---\n",
           directoryName, dir->currentCount, MAX_NUMBERS_PER_DIRECTORY);
    if (dir->currentCount == 0) {
        printf("  Directory is empty.\n");
    } else {
        for (int i = 0; i < dir->currentCount; i++) {
            printf("  %s: %s\n", dir->entries[i].speedDialCode, dir->entries[i].phoneNumber);
        }
    }
}

/**
 * @brief Lists the names of all directories currently managed by the speed dial manager.
 */
void listAllDirectoryNames() {
    if (!manager.initialized) {
        printf("Error: SpeedDialManager not initialized. Call initializeSpeedDialManager() first.\n");
        return;
    }

    printf("\n--- All available directories ---\n");
    for (int i = 0; i < MAX_DIRECTORIES; i++) {
        printf("  %s\n", manager.directories[i].name);
    }
}

/**
 * @brief Frees all dynamically allocated memory used by the SpeedDialManager.
 * This should be called before the program exits to prevent memory leaks.
 */
void freeSpeedDialManager() {
    if (!manager.initialized) {
        printf("SpeedDialManager not initialized or already freed.\n");
        return;
    }

    printf("Freeing SpeedDialManager memory...\n");
    for (int i = 0; i < MAX_DIRECTORIES; i++) {
        if (manager.directories[i].entries != NULL) {
            free(manager.directories[i].entries);
            manager.directories[i].entries = NULL; // Prevent double free
        }
    }
    manager.initialized = false;
    printf("SpeedDialManager memory freed.\n");
}

// --- Main Function (Demonstration) ---
int main() {
    printf("--- Starting C Speed Dial System Demonstration ---\n");

    // 1. Initialize the SpeedDialManager
    initializeSpeedDialManager();

    // 2. List all initial directories
    listAllDirectoryNames();

    // 3. Add some sample numbers to different directories
    printf("\n--- Adding sample numbers ---\n");
    addNumber("Directory 1", "home", "123-456-7890");
    addNumber("Directory 1", "work", "987-654-3210");
    addNumber("Directory 1", "mom", "555-111-2222");
    addNumber("Directory 2", "friend1", "111-222-3333");
    addNumber("Directory 2", "friend2", "444-555-6666");
    addNumber("Directory 5", "emergency", "911");

    // 4. Demonstrate error cases for adding numbers
    printf("\n--- Demonstrating add number error cases ---\n");
    // Try adding to a non-existent directory
    addNumber("Directory 6", "test", "000-000-0000");
    // Try adding a duplicate speed dial code in the same directory
    addNumber("Directory 1", "home", "123-999-8888");

    // 5. Demonstrate directory capacity limit
    printf("\n--- Demonstrating directory capacity limit (filling Directory 3) ---\n");
    // Fill Directory 3 almost to its limit
    for (int i = 0; i < MAX_NUMBERS_PER_DIRECTORY - 1; i++) {
        char code[MAX_CODE_LENGTH];
        char number[MAX_PHONE_LENGTH];
        snprintf(code, MAX_CODE_LENGTH, "contact%d", i);
        snprintf(number, MAX_PHONE_LENGTH, "000-000-%04d", i);
        addNumber("Directory 3", code, number);
    }
    // Try to add one more number to a full directory
    addNumber("Directory 3", "overflow", "999-999-9999");
    listNumbersInDirectory("Directory 3"); // Show the full directory

    // 6. Retrieve numbers
    printf("\n--- Retrieving numbers ---\n");
    const char *momNumber = getPhoneNumber("Directory 1", "mom");
    const char *friend2Number = getPhoneNumber("Directory 2", "friend2");
    const char *nonExistentNumber = getPhoneNumber("Directory 1", "dad"); // Not found
    const char *nonExistentDirNumber = getPhoneNumber("Directory 7", "any"); // Directory not found

    // 7. List numbers in specific directories
    listNumbersInDirectory("Directory 1");
    listNumbersInDirectory("Directory 2");
    listNumbersInDirectory("Directory 4"); // This directory should be empty

    // 8. Remove numbers
    printf("\n--- Removing numbers ---\n");
    removeNumber("Directory 1", "work"); // Successful removal
    removeNumber("Directory 2", "nonexistent"); // Try removing a non-existent entry
    removeNumber("Directory 6", "any"); // Try removing from a non-existent directory

    // 9. List numbers after removal
    listNumbersInDirectory("Directory 1");

    // 10. Free allocated memory
    freeSpeedDialManager();

    printf("\n--- C Speed Dial System Demonstration Complete ---\n");

    return 0; // Indicate successful execution
}
