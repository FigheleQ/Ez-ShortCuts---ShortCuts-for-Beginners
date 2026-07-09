//
//  ShortcutItem.swift
//  ShortCuts For Beginners
//
//  The central data model for the app.
//  Every shortcut shown in the UI comes from the `sampleData` array below.
//

import Foundation

// MARK: - Category

/// The groups shown in the sidebar. Each category has a native SF Symbol.
enum ShortcutCategory: String, CaseIterable, Identifiable {
    case systemEssentials = "System Essentials"
    case textEditing = "Text Editing"
    case webBrowsing = "Web Browsing"
    case windowManagement = "Window Management"
    case finderAndFiles = "Finder & Files"
    case screenshots = "Screenshots"

    // The category itself is the id so it can be used directly
    // as a List selection value.
    var id: Self { self }

    /// SF Symbol name used in the sidebar and detail view.
    var symbolName: String {
        switch self {
        case .systemEssentials: "command"
        case .textEditing: "character.cursor.ibeam"
        case .webBrowsing: "safari"
        case .windowManagement: "macwindow.on.rectangle"
        case .finderAndFiles: "folder"
        case .screenshots: "camera.viewfinder"
        }
    }

    /// A short subtitle shown under the category header.
    var subtitle: String {
        switch self {
        case .systemEssentials: "The shortcuts every Mac user should know"
        case .textEditing: "Write and edit text faster"
        case .webBrowsing: "Navigate Safari and other browsers"
        case .windowManagement: "Control windows and apps"
        case .finderAndFiles: "Manage files and folders like a pro"
        case .screenshots: "Capture anything on your screen"
        }
    }
}

// MARK: - Shortcut Item

/// One keyboard shortcut, including everything the UI needs to display it.
struct ShortcutItem: Identifiable, Hashable {
    let id: UUID
    /// Short name, e.g. "Copy".
    let title: String
    /// A beginner-friendly explanation of what the shortcut does.
    let description: String
    /// The keys in the order they should be pressed, e.g. ["⌘", "C"].
    /// Use the symbols ⌘ ⌥ ⇧ ⌃ for modifier keys.
    let keys: [String]
    let category: ShortcutCategory
    /// Optional video tutorial. `nil` shows a friendly placeholder card.
    let videoURL: URL?
    /// `true` for shortcuts that macOS intercepts before any app can see
    /// them (Spotlight, the app switcher, screenshots, …). Practice Mode
    /// falls back to tap-only practice for these.
    let isSystemCaptured: Bool

    init(title: String,
         description: String,
         keys: [String],
         category: ShortcutCategory,
         videoURL: URL? = nil,
         isSystemCaptured: Bool = false) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.keys = keys
        self.category = category
        self.videoURL = videoURL
        self.isSystemCaptured = isSystemCaptured
    }

    /// Convenience for videos bundled inside the app.
    /// Drag your .mp4/.mov file into the Xcode project (make sure
    /// "Add to target" is checked), then call `.localVideo(named: "MyVideo")`.
    static func localVideo(named name: String, fileExtension: String = "mp4") -> URL? {
        Bundle.main.url(forResource: name, withExtension: fileExtension)
    }
}

// MARK: - DEVELOPER DATA (Add your videos here)
//
//  HOW TO ADD OR UPDATE A SHORTCUT:
//
//  1. Append a new `ShortcutItem` to the array below.
//  2. `keys` is an array of strings — one entry per key cap drawn on screen.
//     Use these symbols for modifiers:  ⌘ (Command)  ⌥ (Option)
//     ⇧ (Shift)  ⌃ (Control)  ⇥ (Tab)  ⎋ (Escape)  ⌫ (Delete)
//     ↩ (Return)  ← → ↑ ↓ (Arrows)
//  3. If macOS itself grabs the shortcut before apps can see it
//     (Spotlight, app switcher, screenshots…), pass
//     `isSystemCaptured: true` so Practice Mode offers tap-only practice.
//  4. To attach a video tutorial, set `videoURL`:
//
//     • Remote video (streamed from the web):
//         videoURL: URL(string: "https://example.com/tutorials/copy-paste.mp4")
//
//       NOTE: For remote videos the app needs the "Outgoing Connections
//       (Client)" capability. In Xcode: Target → Signing & Capabilities →
//       App Sandbox → check "Outgoing Connections (Client)".
//
//     • Local video (bundled with the app):
//         videoURL: ShortcutItem.localVideo(named: "CopyPasteTutorial")
//
//       Drag the video file into the project navigator first.
//
//     • No video yet? Just omit the parameter — the detail view shows a
//       "coming soon" placeholder automatically.
//

extension ShortcutItem {
    static let sampleData: [ShortcutItem] = [

        // MARK: System Essentials
        ShortcutItem(
            title: "Spotlight Search",
            description: "Opens Spotlight so you can instantly find apps, documents, and information on your Mac. This is the fastest way to launch anything.",
            keys: ["⌘", "Space"],
            category: .systemEssentials,
            // Example remote video — replace with your own tutorial URL.
            videoURL: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"),
            isSystemCaptured: true
        ),
        ShortcutItem(
            title: "Copy",
            description: "Copies the selected text, file, or image to the clipboard so you can paste it somewhere else.",
            keys: ["⌘", "C"],
            category: .systemEssentials
        ),
        ShortcutItem(
            title: "Cut",
            description: "Removes the selected text and places it on the clipboard, ready to be pasted somewhere else.",
            keys: ["⌘", "X"],
            category: .systemEssentials
        ),
        ShortcutItem(
            title: "Paste",
            description: "Pastes whatever you copied to the clipboard into the current document or folder.",
            keys: ["⌘", "V"],
            category: .systemEssentials
        ),
        ShortcutItem(
            title: "Undo",
            description: "Reverses your last action. Made a mistake? This shortcut is your best friend.",
            keys: ["⌘", "Z"],
            category: .systemEssentials
        ),
        ShortcutItem(
            title: "Redo",
            description: "Brings back the action you just undid. The opposite of Undo.",
            keys: ["⌘", "⇧", "Z"],
            category: .systemEssentials
        ),
        ShortcutItem(
            title: "New Document or Window",
            description: "Creates a new document, window, or item in almost every app.",
            keys: ["⌘", "N"],
            category: .systemEssentials
        ),
        ShortcutItem(
            title: "Open File",
            description: "Shows the Open dialog so you can pick a file to open in the current app.",
            keys: ["⌘", "O"],
            category: .systemEssentials
        ),
        ShortcutItem(
            title: "Print",
            description: "Opens the Print dialog for the current document or web page.",
            keys: ["⌘", "P"],
            category: .systemEssentials
        ),
        ShortcutItem(
            title: "Open App Settings",
            description: "Opens the settings (preferences) of the app you're currently using. Works in almost every Mac app.",
            keys: ["⌘", ","],
            category: .systemEssentials
        ),
        ShortcutItem(
            title: "Quit App",
            description: "Completely quits the current application, closing all of its windows.",
            keys: ["⌘", "Q"],
            category: .systemEssentials
        ),
        ShortcutItem(
            title: "Force Quit",
            description: "Opens the Force Quit window so you can close an app that has stopped responding.",
            keys: ["⌘", "⌥", "⎋"],
            category: .systemEssentials,
            isSystemCaptured: true
        ),
        ShortcutItem(
            title: "Lock Screen",
            description: "Instantly locks your Mac. Perfect when you step away from your desk.",
            keys: ["⌃", "⌘", "Q"],
            category: .systemEssentials,
            isSystemCaptured: true
        ),
        ShortcutItem(
            title: "Emoji & Symbols",
            description: "Opens the emoji picker so you can insert emoji anywhere you can type. 🎉",
            keys: ["⌃", "⌘", "Space"],
            category: .systemEssentials
        ),

        // MARK: Text Editing
        ShortcutItem(
            title: "Select All",
            description: "Selects all the text or items in the current document or window.",
            keys: ["⌘", "A"],
            category: .textEditing
        ),
        ShortcutItem(
            title: "Find",
            description: "Opens the Find bar so you can search for a word or phrase in the current document.",
            keys: ["⌘", "F"],
            category: .textEditing
        ),
        ShortcutItem(
            title: "Find Next",
            description: "Jumps to the next match after you've searched with Find.",
            keys: ["⌘", "G"],
            category: .textEditing
        ),
        ShortcutItem(
            title: "Bold Text",
            description: "Makes the selected text bold. Press it again to remove the bold style.",
            keys: ["⌘", "B"],
            category: .textEditing
        ),
        ShortcutItem(
            title: "Italic Text",
            description: "Makes the selected text italic. Press it again to switch back to normal.",
            keys: ["⌘", "I"],
            category: .textEditing
        ),
        ShortcutItem(
            title: "Underline Text",
            description: "Underlines the selected text. Press it again to remove the underline.",
            keys: ["⌘", "U"],
            category: .textEditing
        ),
        ShortcutItem(
            title: "Save Document",
            description: "Saves the current document. Save early, save often!",
            keys: ["⌘", "S"],
            category: .textEditing
        ),
        ShortcutItem(
            title: "Jump to Start of Line",
            description: "Moves the cursor to the beginning of the current line — much faster than holding the arrow key.",
            keys: ["⌘", "←"],
            category: .textEditing
        ),
        ShortcutItem(
            title: "Jump to End of Line",
            description: "Moves the cursor to the end of the current line in one press.",
            keys: ["⌘", "→"],
            category: .textEditing
        ),
        ShortcutItem(
            title: "Jump to Start of Document",
            description: "Moves the cursor all the way to the very beginning of the document.",
            keys: ["⌘", "↑"],
            category: .textEditing
        ),
        ShortcutItem(
            title: "Jump to End of Document",
            description: "Moves the cursor all the way to the very end of the document.",
            keys: ["⌘", "↓"],
            category: .textEditing
        ),
        ShortcutItem(
            title: "Jump to Previous Word",
            description: "Moves the cursor one whole word to the left instead of one letter at a time.",
            keys: ["⌥", "←"],
            category: .textEditing
        ),
        ShortcutItem(
            title: "Jump to Next Word",
            description: "Moves the cursor one whole word to the right instead of one letter at a time.",
            keys: ["⌥", "→"],
            category: .textEditing
        ),
        ShortcutItem(
            title: "Delete Whole Word",
            description: "Deletes the entire word to the left of the cursor in one press.",
            keys: ["⌥", "⌫"],
            category: .textEditing
        ),
        ShortcutItem(
            title: "Delete to Start of Line",
            description: "Deletes everything from the cursor back to the beginning of the line.",
            keys: ["⌘", "⌫"],
            category: .textEditing
        ),

        // MARK: Web Browsing
        ShortcutItem(
            title: "New Tab",
            description: "Opens a new tab in your browser so you can visit another page without losing your place.",
            keys: ["⌘", "T"],
            category: .webBrowsing
        ),
        ShortcutItem(
            title: "Reopen Closed Tab",
            description: "Accidentally closed a tab? This brings back the tab you just closed.",
            keys: ["⌘", "⇧", "T"],
            category: .webBrowsing
        ),
        ShortcutItem(
            title: "Next Tab",
            description: "Switches to the tab on the right, so you can flip through your open tabs.",
            keys: ["⌃", "⇥"],
            category: .webBrowsing
        ),
        ShortcutItem(
            title: "Previous Tab",
            description: "Switches to the tab on the left — the reverse of Next Tab.",
            keys: ["⌃", "⇧", "⇥"],
            category: .webBrowsing
        ),
        ShortcutItem(
            title: "Focus Address Bar",
            description: "Jumps straight to the address bar so you can type a web address or search immediately.",
            keys: ["⌘", "L"],
            category: .webBrowsing
        ),
        ShortcutItem(
            title: "Reload Page",
            description: "Reloads the current web page to show the latest content.",
            keys: ["⌘", "R"],
            category: .webBrowsing
        ),
        ShortcutItem(
            title: "Go Back",
            description: "Goes back to the previous page, just like the Back button.",
            keys: ["⌘", "["],
            category: .webBrowsing
        ),
        ShortcutItem(
            title: "Go Forward",
            description: "Goes forward again after you've gone back.",
            keys: ["⌘", "]"],
            category: .webBrowsing
        ),
        ShortcutItem(
            title: "Private Browsing Window",
            description: "Opens a new private window that doesn't remember your browsing history.",
            keys: ["⌘", "⇧", "N"],
            category: .webBrowsing
        ),
        ShortcutItem(
            title: "Bookmark This Page",
            description: "Saves the current page to your bookmarks so you can find it again later.",
            keys: ["⌘", "D"],
            category: .webBrowsing
        ),
        ShortcutItem(
            title: "Zoom In",
            description: "Makes the text and images on the page bigger and easier to read.",
            keys: ["⌘", "+"],
            category: .webBrowsing
        ),
        ShortcutItem(
            title: "Zoom Out",
            description: "Makes the page smaller so more of it fits on your screen.",
            keys: ["⌘", "-"],
            category: .webBrowsing
        ),
        ShortcutItem(
            title: "Actual Size",
            description: "Resets the page zoom back to its normal size.",
            keys: ["⌘", "0"],
            category: .webBrowsing
        ),
        ShortcutItem(
            title: "Show Downloads",
            description: "Opens the list of files you've downloaded from the web.",
            keys: ["⌘", "⌥", "L"],
            category: .webBrowsing
        ),

        // MARK: Window Management
        ShortcutItem(
            title: "Switch Between Apps",
            description: "Opens the app switcher. Keep holding ⌘ and tap Tab to cycle through your open apps.",
            keys: ["⌘", "⇥"],
            category: .windowManagement,
            isSystemCaptured: true
        ),
        ShortcutItem(
            title: "Switch App Windows",
            description: "Cycles between the open windows of the app you're currently using.",
            keys: ["⌘", "`"],
            category: .windowManagement
        ),
        ShortcutItem(
            title: "Minimize Window",
            description: "Minimizes the current window into the Dock.",
            keys: ["⌘", "M"],
            category: .windowManagement
        ),
        ShortcutItem(
            title: "Minimize All Windows",
            description: "Minimizes every window of the current app into the Dock at once.",
            keys: ["⌘", "⌥", "M"],
            category: .windowManagement
        ),
        ShortcutItem(
            title: "Hide App",
            description: "Instantly hides all windows of the current app. Click its Dock icon to bring them back.",
            keys: ["⌘", "H"],
            category: .windowManagement
        ),
        ShortcutItem(
            title: "Hide Other Apps",
            description: "Hides every app except the one you're using — instant focus.",
            keys: ["⌘", "⌥", "H"],
            category: .windowManagement
        ),
        ShortcutItem(
            title: "Close Window",
            description: "Closes the current window or tab without quitting the app.",
            keys: ["⌘", "W"],
            category: .windowManagement
        ),
        ShortcutItem(
            title: "Enter Full Screen",
            description: "Expands the current window to fill the whole screen. Press it again to exit.",
            keys: ["⌃", "⌘", "F"],
            category: .windowManagement
        ),
        ShortcutItem(
            title: "Mission Control",
            description: "Shows every open window at once so you can quickly jump to any of them.",
            keys: ["⌃", "↑"],
            category: .windowManagement,
            isSystemCaptured: true
        ),

        // MARK: Finder & Files
        ShortcutItem(
            title: "New Finder Window",
            description: "Opens a fresh Finder window so you can browse your files.",
            keys: ["⌘", "N"],
            category: .finderAndFiles
        ),
        ShortcutItem(
            title: "New Folder",
            description: "Creates a new, empty folder in the current location.",
            keys: ["⌘", "⇧", "N"],
            category: .finderAndFiles
        ),
        ShortcutItem(
            title: "Duplicate File",
            description: "Makes an exact copy of the selected file or folder right next to the original.",
            keys: ["⌘", "D"],
            category: .finderAndFiles
        ),
        ShortcutItem(
            title: "Get Info",
            description: "Shows detailed information about the selected file: its size, kind, location, and more.",
            keys: ["⌘", "I"],
            category: .finderAndFiles
        ),
        ShortcutItem(
            title: "Quick Look",
            description: "Previews the selected file instantly without opening any app. Press Space again to close it.",
            keys: ["Space"],
            category: .finderAndFiles
        ),
        ShortcutItem(
            title: "Rename File",
            description: "With a file selected in Finder, press Return to start renaming it.",
            keys: ["↩"],
            category: .finderAndFiles
        ),
        ShortcutItem(
            title: "Move to Trash",
            description: "Moves the selected files to the Trash. Don't worry — nothing is deleted until you empty it.",
            keys: ["⌘", "⌫"],
            category: .finderAndFiles
        ),
        ShortcutItem(
            title: "Empty Trash",
            description: "Permanently deletes everything in the Trash. Finder will ask you to confirm first.",
            keys: ["⌘", "⇧", "⌫"],
            category: .finderAndFiles
        ),
        ShortcutItem(
            title: "Go to Home Folder",
            description: "Jumps straight to your Home folder in Finder.",
            keys: ["⌘", "⇧", "H"],
            category: .finderAndFiles
        ),
        ShortcutItem(
            title: "Go to Desktop",
            description: "Jumps straight to your Desktop folder in Finder.",
            keys: ["⌘", "⇧", "D"],
            category: .finderAndFiles
        ),
        ShortcutItem(
            title: "Go to Applications",
            description: "Opens your Applications folder, where all your apps live.",
            keys: ["⌘", "⇧", "A"],
            category: .finderAndFiles
        ),
        ShortcutItem(
            title: "Go to a Folder",
            description: "Opens a box where you can type the path of any folder and jump straight to it.",
            keys: ["⌘", "⇧", "G"],
            category: .finderAndFiles
        ),
        ShortcutItem(
            title: "Show Hidden Files",
            description: "Reveals files that are normally hidden in Finder. Press it again to hide them.",
            keys: ["⌘", "⇧", "."],
            category: .finderAndFiles
        ),
        ShortcutItem(
            title: "Eject Disk",
            description: "Safely ejects the selected disk or USB drive so you can unplug it.",
            keys: ["⌘", "E"],
            category: .finderAndFiles
        ),

        // MARK: Screenshots
        ShortcutItem(
            title: "Capture Entire Screen",
            description: "Takes a picture of your whole screen and saves it to the Desktop.",
            keys: ["⌘", "⇧", "3"],
            category: .screenshots,
            isSystemCaptured: true
        ),
        ShortcutItem(
            title: "Capture a Portion",
            description: "Turns your cursor into a crosshair so you can drag over exactly the area you want to capture.",
            keys: ["⌘", "⇧", "4"],
            category: .screenshots,
            isSystemCaptured: true
        ),
        ShortcutItem(
            title: "Capture a Window",
            description: "Press ⌘⇧4, then tap Space — the cursor becomes a camera and one click captures a whole window.",
            keys: ["⌘", "⇧", "4", "Space"],
            category: .screenshots,
            isSystemCaptured: true
        ),
        ShortcutItem(
            title: "Screenshot Toolbar",
            description: "Opens the screenshot toolbar with every capture option, including screen recording.",
            keys: ["⌘", "⇧", "5"],
            category: .screenshots,
            isSystemCaptured: true
        )
    ]
}
