#include <stdio.h> // For printf (for demonstration purposes, replace with actual UART/LCD output)
#include <string.h> // For strcpy

// Define the maximum number of speed dial entries
#define MAX_SPEED_DIALS 10
// Define the maximum length of a phone number string
#define MAX_PHONE_NUMBER_LEN 15

// Structure to hold a speed dial entry
typedef struct {
    char phoneNumber[MAX_PHONE_NUMBER_LEN];
    char contactName[20]; // Optional: to store a name
} SpeedDialEntry;

// Array to store speed dial entries
// Initialize with empty strings or default values
SpeedDialEntry speedDialList[MAX_SPEED_DIALS] = {0};

/**
 * @brief Initializes the speed dial list with some default entries.
 * In a real microcontroller, these might be loaded from EEPROM or flash.
 */
void initializeSpeedDial() {
    // Example entries (replace with your actual numbers)
    strcpy(speedDialList[0].phoneNumber, "9876543210");
    strcpy(speedDialList[0].contactName, "Emergency");

    strcpy(speedDialList[1].phoneNumber, "1234567890");
    strcpy(speedDialList[1].contactName, "Home");

    strcpy(speedDialList[2].phoneNumber, "5551234567");
    strcpy(speedDialList[2].contactName, "Work");

    // You can add more entries up to MAX_SPEED_DIALS - 1
    // For unassigned entries, the phoneNumber will remain empty if initialized to 0
    printf("Speed dial initialized.\n");
}

/**
 * @brief Assigns a phone number and optional name to a speed dial index.
 * @param index The speed dial index (0 to MAX_SPEED_DIALS - 1).
 * @param number The phone number string to assign.
 * @param name The contact name string to assign (can be NULL or empty string).
 * @return 0 on success, -1 on failure (invalid index or number too long).
 */
int assignSpeedDial(int index, const char* number, const char* name) {
    if (index < 0 || index >= MAX_SPEED_DIALS) {
        printf("Error: Invalid speed dial index %d. Must be between 0 and %d.\n", index, MAX_SPEED_DIALS - 1);
        return -1;
    }
    if (strlen(number) >= MAX_PHONE_NUMBER_LEN) {
        printf("Error: Phone number too long for speed dial %d.\n", index);
        return -1;
    }

    strcpy(speedDialList[index].phoneNumber, number);
    if (name != NULL && strlen(name) < sizeof(speedDialList[index].contactName)) {
        strcpy(speedDialList[index].contactName, name);
    } else {
        speedDialList[index].contactName[0] = '\0'; // Clear name if not provided or too long
    }

    printf("Assigned speed dial %d: %s (%s)\n", index, speedDialList[index].phoneNumber, speedDialList[index].contactName);
    return 0;
}

/**
 * @brief Retrieves the phone number for a given speed dial index.
 * @param index The speed dial index.
 * @return A pointer to the phone number string if found, or NULL if invalid index or not assigned.
 */
const char* getSpeedDialNumber(int index) {
    if (index < 0 || index >= MAX_SPEED_DIALS) {
        printf("Error: Invalid speed dial index %d.\n", index);
        return NULL;
    }
    if (speedDialList[index].phoneNumber[0] == '\0') { // Check if the entry is empty
        printf("Speed dial %d is not assigned.\n", index);
        return NULL;
    }
    return speedDialList[index].phoneNumber;
}

/**
 * @brief "Dials" the number associated with the given speed dial index.
 * In a real microcontroller, this would involve sending commands to a GSM/LTE module.
 * @param index The speed dial index to dial.
 */
void dialSpeedDial(int index) {
    const char* numberToDial = getSpeedDialNumber(index);
    if (numberToDial != NULL) {
        printf("Attempting to dial: %s (from speed dial %d - %s)\n", numberToDial, index, speedDialList[index].contactName);
        // --- Microcontroller specific code would go here ---
        // Example: sendATCommand("ATD%s;\r\n", numberToDial);
        // Or trigger a function to control a communication module
        // ---------------------------------------------------
    } else {
        printf("Cannot dial. Speed dial %d is not valid or assigned.\n", index);
    }
}

/**
 * @brief Main function to demonstrate the speed dial functionality.
 * In a microcontroller, this would be part of your main loop.
 */
int main() {
    initializeSpeedDial();

    printf("\n--- Demonstrating Speed Dial ---\n");

    // Simulate user input or events
    printf("\nSimulating dialing speed dial 1...\n");
    dialSpeedDial(1); // Should dial "Home"

    printf("\nSimulating dialing speed dial 0...\n");
    dialSpeedDial(0); // Should dial "Emergency"

    printf("\nSimulating dialing an unassigned speed dial 5...\n");
    dialSpeedDial(5); // Should report not assigned

    printf("\nAssigning new speed dial 5...\n");
    assignSpeedDial(5, "9998887777", "Friend");

    printf("\nSimulating dialing newly assigned speed dial 5...\n");
    dialSpeedDial(5);

    printf("\n--- End of Demonstration ---\n");

    return 0;
}
