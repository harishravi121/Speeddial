import SwiftUI
import Foundation // For String operations and other basic types

// --- Constants ---
let MAX_DIRECTORIES = 5
let TOTAL_NUMBERS = 1000
let MAX_NUMBERS_PER_DIRECTORY = TOTAL_NUMBERS / MAX_DIRECTORIES // 200 numbers per directory

// --- Data Structures ---

/**
 * @brief Represents a single speed dial entry.
 * Stores a unique speed dial code and its corresponding phone number.
 * Conforms to Identifiable for use in SwiftUI Lists.
 */
struct SpeedDialEntry: Identifiable, Hashable {
    let id = UUID() // Unique ID for SwiftUI List identification
    let speedDialCode: String
    let phoneNumber: String

    // Custom initializer to make it easier to create entries
    init(speedDialCode: String, phoneNumber: String) {
        self.speedDialCode = speedDialCode
        self.phoneNumber = phoneNumber
    }
}

/**
 * @brief Represents a single directory within the speed dial system.
 * Contains a name and a dictionary of speed dial entries.
 * Conforms to Identifiable for use in SwiftUI Lists.
 */
class Directory: ObservableObject, Identifiable, Hashable {
    let id = UUID() // Unique ID for SwiftUI List identification
    let name: String
    // Using a Dictionary for entries for efficient lookup by speedDialCode
    // @Published makes changes to 'entries' automatically refresh SwiftUI views.
    @Published private var entries: [String: String] = [:]

    init(name: String) {
        self.name = name
    }

    // Conformance to Hashable for use in NavigationLink value
    static func == (lhs: Directory, rhs: Directory) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    /**
     * @brief Adds a speed dial entry to this directory.
     * @param speedDialCode The unique code for the entry.
     * @param phoneNumber The phone number to store.
     * @return true if added successfully, false if full or code already exists.
     */
    func addEntry(speedDialCode: String, phoneNumber: String) -> Bool {
        if entries.count >= MAX_NUMBERS_PER_DIRECTORY {
            print("Error: Directory '\(name)' is full. Max \(MAX_NUMBERS_PER_DIRECTORY) numbers allowed. Cannot add number.")
            return false
        }
        if entries[speedDialCode] != nil {
            print("Error: Speed dial code '\(speedDialCode)' already exists in '\(name)'. Cannot add duplicate.")
            return false
        }
        entries[speedDialCode] = phoneNumber
        return true
    }

    /**
     * @brief Retrieves a phone number from this directory.
     * @param speedDialCode The code to look up.
     * @return The phone number string if found, otherwise nil.
     */
    func getEntry(speedDialCode: String) -> String? {
        return entries[speedDialCode]
    }

    /**
     * @brief Removes a speed dial entry from this directory.
     * @param speedDialCode The code of the entry to remove.
     * @return true if removed successfully, false if code not found.
     */
    func removeEntry(speedDialCode: String) -> Bool {
        if entries.removeValue(forKey: speedDialCode) != nil {
            return true
        }
        return false
    }

    /**
     * @brief Returns the current count of entries in this directory.
     */
    var currentCount: Int {
        return entries.count
    }

    /**
     * @brief Returns an array of SpeedDialEntry objects for SwiftUI List.
     */
    func getSpeedDialEntries() -> [SpeedDialEntry] {
        return entries.map { SpeedDialEntry(speedDialCode: $0.key, phoneNumber: $0.value) }
                     .sorted { $0.speedDialCode < $1.speedDialCode } // Sort for consistent display
    }
}

/**
 * @brief Manages the entire speed dial system.
 * Contains a dictionary of Directory objects.
 * Conforms to ObservableObject to allow SwiftUI views to observe its changes.
 */
class SpeedDialManager: ObservableObject {
    // @Published makes changes to 'directories' automatically refresh SwiftUI views.
    @Published private var directories: [String: Directory] = [:]
    private var initialized: Bool = false

    init() {
        // Initialization logic is now in a separate method to match C structure,
        // but could also be directly in init() for a more Swift-idiomatic approach.
    }

    /**
     * @brief Initializes the SpeedDialManager.
     * Sets up the predefined number of directories.
     */
    func initializeSpeedDialManager() {
        if initialized {
            print("SpeedDialManager already initialized.")
            return
        }

        print("Initializing SpeedDialManager with \(MAX_DIRECTORIES) directories...")
        for i in 1...MAX_DIRECTORIES {
            let dirName = "Directory \(i)"
            directories[dirName] = Directory(name: dirName)
        }
        initialized = true
        print("SpeedDialManager initialized successfully.")
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
    func addNumber(directoryName: String, speedDialCode: String, phoneNumber: String) -> Bool {
        guard initialized else {
            print("Error: SpeedDialManager not initialized. Call initializeSpeedDialManager() first.")
            return false
        }

        guard let directory = directories[directoryName] else {
            print("Error: Directory '\(directoryName)' does not exist. Cannot add number.")
            return false
        }

        // Use directory's addEntry method which handles its own @Published updates
        if directory.addEntry(speedDialCode: speedDialCode, phoneNumber: phoneNumber) {
            print("Successfully added '\(speedDialCode)' -> '\(phoneNumber)' to '\(directoryName)'.")
            return true
        } else {
            // Error message already printed by directory.addEntry
            return false
        }
    }

    /**
     * @brief Retrieves a phone number from a specified speed dial directory using its speed dial code.
     *
     * @param directoryName The name of the directory to search within.
     * @param speedDialCode The speed dial code associated with the desired phone number.
     * @return The phone number as a String if found; nil if the directory does not exist
     * or the speed dial code is not found within the directory.
     */
    func getPhoneNumber(directoryName: String, speedDialCode: String) -> String? {
        guard initialized else {
            print("Error: SpeedDialManager not initialized. Call initializeSpeedDialManager() first.")
            return nil
        }

        guard let directory = directories[directoryName] else {
            print("Error: Directory '\(directoryName)' does not exist. Cannot retrieve number.")
            return nil
        }

        if let phoneNumber = directory.getEntry(speedDialCode: speedDialCode) {
            print("Retrieved '\(speedDialCode)' from '\(directoryName)': \(phoneNumber)")
            return phoneNumber
        } else {
            print("Phone number for speed dial code '\(speedDialCode)' not found in '\(directoryName)'.")
            return nil
        }
    }

    /**
     * @brief Removes a speed dial entry from a specified directory.
     *
     * @param directoryName The name of the directory from which to remove the entry.
     * @param speedDialCode The speed dial code of the entry to be removed.
     * @return true if the entry was successfully removed; false if the directory does not exist
     * or the speed dial code was not found in the directory.
     */
    func removeNumber(directoryName: String, speedDialCode: String) -> Bool {
        guard initialized else {
            print("Error: SpeedDialManager not initialized. Call initializeSpeedDialManager() first.")
            return false
        }

        guard let directory = directories[directoryName] else {
            print("Error: Directory '\(directoryName)' does not exist. Cannot remove number.")
            return false
        }

        // Use directory's removeEntry method which handles its own @Published updates
        if directory.removeEntry(speedDialCode: speedDialCode) {
            print("Successfully removed '\(speedDialCode)' from '\(directoryName)'.")
            return true
        } else {
            print("Speed dial code '\(speedDialCode)' not found in '\(directoryName)'. No number removed.")
            return false
        }
    }

    /**
     * @brief Returns an array of all Directory objects for SwiftUI List.
     */
    func getAllDirectories() -> [Directory] {
        return directories.values.sorted { $0.name < $1.name } // Sort for consistent display
    }
}

// --- SwiftUI Views ---

/**
 * @brief The main application entry point.
 * Sets up the window group and the initial view.
 */
@main
struct SpeedDialApp: App {
    // Create a single instance of SpeedDialManager for the entire app
    @StateObject var speedDialManager = SpeedDialManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(speedDialManager) // Make manager available to all subviews
                .onAppear {
                    // Initialize the manager when the app starts
                    speedDialManager.initializeSpeedDialManager()
                    // Add some sample data for demonstration
                    speedDialManager.addNumber(directoryName: "Directory 1", speedDialCode: "home", phoneNumber: "123-456-7890")
                    speedDialManager.addNumber(directoryName: "Directory 1", speedDialCode: "work", phoneNumber: "987-654-3210")
                    speedDialManager.addNumber(directoryName: "Directory 1", speedDialCode: "mom", phoneNumber: "555-111-2222")
                    speedDialManager.addNumber(directoryName: "Directory 2", speedDialCode: "friend1", phoneNumber: "111-222-3333")
                    speedDialManager.addNumber(directoryName: "Directory 2", speedDialCode: "friend2", phoneNumber: "444-555-6666")
                    speedDialManager.addNumber(directoryName: "Directory 5", speedDialCode: "emergency", phoneNumber: "911")
                }
        }
    }
}

/**
 * @brief The main content view of the application.
 * Displays a list of directories and allows navigation into each.
 */
struct ContentView: View {
    // Access the shared SpeedDialManager from the environment
    @EnvironmentObject var speedDialManager: SpeedDialManager

    var body: some View {
        NavigationView {
            List {
                // Iterate over the directories provided by the manager
                ForEach(speedDialManager.getAllDirectories()) { directory in
                    NavigationLink(value: directory) { // Use value-based navigation for iOS 16+
                        HStack {
                            Text(directory.name)
                            Spacer()
                            Text("(\(directory.currentCount)/\(MAX_NUMBERS_PER_DIRECTORY))")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 4) // Add some vertical padding
                    }
                }
            }
            .navigationTitle("Speed Dial Directories")
            .navigationDestination(for: Directory.self) { directory in // iOS 16+ navigation
                DirectoryDetailView(directory: directory)
            }
        }
        // Apply a consistent font to the entire view hierarchy
        .font(.custom("Inter", size: 17))
        .accentColor(.blue) // Set a consistent accent color for navigation links, etc.
    }
}

/**
 * @brief A view to display details of a specific directory.
 * Shows speed dial entries and allows adding/removing numbers.
 */
struct DirectoryDetailView: View {
    // Observe changes to the specific Directory object
    @ObservedObject var directory: Directory

    // State for showing the add number sheet
    @State private var showingAddNumberSheet = false
    // State for showing the dial confirmation alert
    @State private var showingDialAlert = false
    @State private var dialedNumber: String = ""
    @State private var dialedCode: String = ""
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""

    var body: some View {
        List {
            // Display each speed dial entry
            ForEach(directory.getSpeedDialEntries()) { entry in
                HStack {
                    Text(entry.speedDialCode)
                        .fontWeight(.medium)
                    Spacer()
                    Text(entry.phoneNumber)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
                .contentShape(Rectangle()) // Make the whole row tappable for context menu
                .onTapGesture {
                    // Simulate dialing on tap
                    dialedCode = entry.speedDialCode
                    dialedNumber = entry.phoneNumber
                    alertTitle = "Dialing \(entry.speedDialCode)"
                    alertMessage = "Calling \(entry.phoneNumber)..."
                    showingDialAlert = true
                }
                .swipeActions(edge: .trailing) { // Swipe to delete
                    Button(role: .destructive) {
                        _ = directory.removeEntry(speedDialCode: entry.speedDialCode)
                    } label: {
                        Label("Delete", systemImage: "trash.fill")
                    }
                }
            }
        }
        .navigationTitle(directory.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddNumberSheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
        }
        .sheet(isPresented: $showingAddNumberSheet) {
            // Present the AddNumberView as a modal sheet
            AddNumberView(directory: directory, isShowingSheet: $showingAddNumberSheet)
        }
        .alert(alertTitle, isPresented: $showingDialAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        // Apply a consistent font to the entire view hierarchy
        .font(.custom("Inter", size: 17))
    }
}

/**
 * @brief A modal view for adding a new speed dial number to a directory.
 */
struct AddNumberView: View {
    @ObservedObject var directory: Directory // The directory to add to
    @Binding var isShowingSheet: Bool // Binding to dismiss the sheet

    @State private var speedDialCode: String = ""
    @State private var phoneNumber: String = ""
    @State private var showingAddResultAlert = false
    @State private var addResultTitle: String = ""
    @State private var addResultMessage: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section("New Speed Dial Entry") {
                    TextField("Speed Dial Code (e.g., 'Mom', 'Work')", text: $speedDialCode)
                        .autocapitalization(.words)
                        .disableAutocorrection(true)
                    TextField("Phone Number (e.g., '123-456-7890')", text: $phoneNumber)
                        .keyboardType(.phonePad) // Suggest phone number keyboard
                }

                Button("Add Number") {
                    if speedDialCode.isEmpty || phoneNumber.isEmpty {
                        addResultTitle = "Input Error"
                        addResultMessage = "Please enter both a speed dial code and a phone number."
                    } else {
                        let success = directory.addEntry(speedDialCode: speedDialCode, phoneNumber: phoneNumber)
                        if success {
                            addResultTitle = "Success!"
                            addResultMessage = "Number added to \(directory.name)."
                            // Optionally dismiss the sheet immediately on success
                            isShowingSheet = false
                        } else {
                            // Error message already printed by directory.addEntry, but show alert too
                            addResultTitle = "Failed to Add Number"
                            addResultMessage = "The speed dial code might already exist or the directory is full."
                        }
                    }
                    showingAddResultAlert = true
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(speedDialCode.isEmpty || phoneNumber.isEmpty) // Disable button if inputs are empty
            }
            .navigationTitle("Add Number to \(directory.name)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isShowingSheet = false // Dismiss the sheet
                    }
                }
            }
        }
        .alert(addResultTitle, isPresented: $showingAddResultAlert) {
            Button("OK") { }
        } message: {
            Text(addResultMessage)
        }
        // Apply a consistent font to the entire view hierarchy
        .font(.custom("Inter", size: 17))
    }
}

// --- Preview Provider (for Xcode Canvas) ---
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(SpeedDialManager()) // Provide a manager for preview
    }
}
