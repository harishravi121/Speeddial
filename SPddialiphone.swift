import Foundation // For String operations and basic types
import UIKit // For simulating phone calls (openURL)

// MARK: - 1. Contact Structure

/// Represents a contact with a name and phone number.
struct Contact {
    let name: String
    let phoneNumber: String
}

// MARK: - 2. SpeedDialManager Class

/// Manages speed dial entries, mapping an integer key to a Contact.
class SpeedDialManager {
    // Dictionary to store speed dial entries: Int (speed dial number) -> Contact
    private var speedDialEntries: [Int: Contact] = [:]

    init() {
        print("Speed Dial Manager initialized.")
        // Optionally, load saved speed dial entries here (e.g., from UserDefaults or Core Data)
    }

    /**
     * Adds a new entry to the speed dial.
     * If the speed dial number already exists, it updates the contact.
     *
     * - Parameters:
     * - speedDialNumber: The integer key for the speed dial.
     * - contact: The Contact object to store.
     */
    func addEntry(speedDialNumber: Int, contact: Contact) {
        guard speedDialNumber > 0 else {
            print("Error: Speed dial number must be positive.")
            return
        }
        speedDialEntries[speedDialNumber] = contact
        print("Added/Updated speed dial \(speedDialNumber): \(contact.name) - \(contact.phoneNumber)")
        // In a real app, you might save this change to persistent storage here.
    }

    /**
     * Retrieves the contact associated with a given speed dial number.
     *
     * - Parameter speedDialNumber: The speed dial number to look up.
     * - Returns: The Contact object if found, otherwise nil.
     */
    func getContact(for speedDialNumber: Int) -> Contact? {
        return speedDialEntries[speedDialNumber]
    }

    /**
     * Removes an entry from the speed dial.
     *
     * - Parameter speedDialNumber: The speed dial number of the entry to remove.
     */
    func removeEntry(speedDialNumber: Int) {
        if let removedContact = speedDialEntries.removeValue(forKey: speedDialNumber) {
            print("Removed speed dial \(speedDialNumber): \(removedContact.name)")
            // In a real app, you might save this change to persistent storage here.
        } else {
            print("Speed dial \(speedDialNumber) does not exist.")
        }
    }

    /**
     * Displays all current speed dial entries.
     */
    func listEntries() {
        if speedDialEntries.isEmpty {
            print("No speed dial entries found.")
            return
        }
        print("\n--- Current Speed Dial Entries ---")
        // Sort entries by key for consistent display
        let sortedEntries = speedDialEntries.sorted { $0.key < $1.key }
        for (number, contact) in sortedEntries {
            print("Speed Dial \(number): \(contact.name) (\(contact.phoneNumber))")
        }
        print("----------------------------------\n")
    }

    /**
     * Simulates "dialing" the number associated with the given speed dial index.
     * In a real iPhone app, this would attempt to open the phone app.
     *
     * - Parameter speedDialNumber: The speed dial number to dial.
     */
    func dialSpeedDial(speedDialNumber: Int) {
        if let contactToDial = getContact(for: speedDialNumber) {
            print("Attempting to dial: \(contactToDial.phoneNumber) (from speed dial \(speedDialNumber) - \(contactToDial.name))")

            // --- iPhone specific code to initiate a call ---
            // This part requires running on an actual device with phone capabilities.
            // For a real app, you would typically use:
            // if let url = URL(string: "telprompt://\(contactToDial.phoneNumber.filter("0123456789".contains))") {
            //     // Use telprompt for a confirmation prompt, or tel for direct dialing
            //     // Ensure the app has appropriate permissions and is on a device with phone capabilities.
            //     // You might also use CallKit for a more integrated experience.
            //     if UIApplication.shared.canOpenURL(url) {
            //         UIApplication.shared.open(url, options: [:], completionHandler: nil)
            //         print("Opened phone app to dial \(contactToDial.phoneNumber)")
            //     } else {
            //         print("Cannot open URL for dialing. Check device capabilities or URL format.")
            //     }
            // } else {
            //     print("Invalid phone number format for URL.")
            // }
            // -------------------------------------------------

            // For demonstration purposes in a playground, we just print:
            print("Simulated call to \(contactToDial.phoneNumber)")

        } else {
            print("Cannot dial. Speed dial \(speedDialNumber) is not valid or assigned.")
        }
    }
}

// MARK: - 3. Demonstration (Similar to main() in C)

// Create an instance of the SpeedDialManager
let mySpeedDial = SpeedDialManager()

// Add some speed dial entries
mySpeedDial.addEntry(speedDialNumber: 1, contact: Contact(name: "Mom", phoneNumber: "111-222-3333"))
mySpeedDial.addEntry(speedDialNumber: 2, contact: Contact(name: "Dad", phoneNumber: "444-555-6666"))
mySpeedDial.addEntry(speedDialNumber: 9, contact: Contact(name: "Emergency Services", phoneNumber: "911"))

// List all current entries
mySpeedDial.listEntries()

// Simulate dialing
print("\nSimulating dialing speed dial 1...")
mySpeedDial.dialSpeedDial(speedDialNumber: 1)

print("\nSimulating dialing speed dial 5 (unassigned)...")
mySpeedDial.dialSpeedDial(speedDialNumber: 5)

// Assign a new speed dial
print("\nAssigning new speed dial 5...")
mySpeedDial.addEntry(speedDialNumber: 5, contact: Contact(name: "Best Friend", phoneNumber: "777-888-9999"))

// Simulate dialing the newly assigned speed dial
print("\nSimulating dialing newly assigned speed dial 5...")
mySpeedDial.dialSpeedDial(speedDialNumber: 5)

// Remove an entry
print("\nRemoving speed dial 2...")
mySpeedDial.removeEntry(speedDialNumber: 2)

// List entries again to see the change
mySpeedDial.listEntries()

