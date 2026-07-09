# ⌨️ ShortCuts For Beginners

> A native macOS app that turns learning keyboard shortcuts from a chore into an interactive experience — browse, practice with tap or real keyboard, and watch video tutorials, all in one clean three-column interface.

---

## Screenshots

> _Add screenshots here after your first run — drag images into this section on GitHub._

---

## Key Features

- **70+ shortcuts across 6 categories** — System Essentials, Text Editing, Web Browsing, Window Management, Finder & Files, and Screenshots
- **Practice Mode — two ways to train:**
  - Tap the on-screen key caps in order with visual highlighting and haptic feedback
  - Press the real shortcut on your physical keyboard — the app detects modifier keys live and validates the full combination
- **Smart system-shortcut detection** — shortcuts that macOS intercepts (Spotlight, ⌘⇥, screenshots…) are flagged automatically; the app explains why and falls back to tap-only practice
- **Video tutorial card** — each shortcut can have a bundled or remote `.mp4`/`.mov` tutorial that plays inline via AVKit; a friendly placeholder is shown when no video is attached yet
- **Native three-column SwiftUI layout** — sidebar (categories) → list (shortcuts) → detail, built with `NavigationSplitView` for a proper macOS feel
- **Styled key caps** — `KeyCapView` renders every key to look like a physical keycap, with a pressed-state animation used by Practice Mode
- **MVVM architecture** with Swift `@Observable` — clean separation between data, view model, and views

---

## Requirements

| Requirement | Minimum |
|---|---|
| macOS | 14 Sonoma |
| Xcode | 16.0 |
| Swift | 5.10 |

---

## Installation

### Clone and open in Xcode

```bash
git clone https://github.com/YOUR_USERNAME/shortcuts-for-beginners.git
cd shortcuts-for-beginners
open "ShortCuts For Beginners.xcodeproj"
```

### Run

1. In Xcode select the **ShortCuts For Beginners** scheme and any **My Mac** destination.
2. Press **⌘R** — the app builds and launches.

No third-party dependencies or Swift Package Manager packages are required.

---

## Project Structure

```
ShortCuts For Beginners/
├── ShortCuts For Beginners/
│   ├── ShortCuts_For_BeginnersApp.swift   # App entry point
│   ├── ContentView.swift                  # NavigationSplitView root
│   ├── ShortcutDetailView.swift           # Detail + Practice Mode + Video card
│   ├── KeyCapView.swift                   # Styled key cap & key row components
│   ├── ShortcutItem.swift                 # Data model + all 70+ shortcuts
│   ├── ShortcutsViewModel.swift           # @Observable view model (MVVM)
│   └── Assets.xcassets
├── ShortCuts For BeginnersTests/
│   └── ShortCuts_For_BeginnersTests.swift # Unit tests (Swift Testing)
└── ShortCuts For BeginnersUITests/
    └── ShortCuts_For_BeginnersUITests.swift
```

---

## Quickstart — Adding a New Shortcut

Open `ShortcutItem.swift` and append a new item to the `sampleData` array:

```swift
ShortcutItem(
    title: "New Finder Window",
    description: "Opens a fresh Finder window so you can browse your files.",
    keys: ["⌘", "N"],
    category: .finderAndFiles
)
```

**Modifier symbols to use in `keys`:**

| Symbol | Key |
|---|---|
| `⌘` | Command |
| `⇧` | Shift |
| `⌥` | Option |
| `⌃` | Control |
| `⎋` | Escape |
| `⌫` | Delete |
| `↩` | Return |
| `⇥` | Tab |

### Attach a video tutorial

```swift
// Remote video (requires "Outgoing Connections" in App Sandbox):
videoURL: URL(string: "https://example.com/my-tutorial.mp4")

// Video bundled in the app (drag the file into the project first):
videoURL: ShortcutItem.localVideo(named: "MyTutorial")
```

### Mark a system-captured shortcut

If macOS intercepts the shortcut before any app can see it (e.g. Spotlight, ⌘⇥), add:

```swift
isSystemCaptured: true
```

Practice Mode will show an explanation and offer tap-only practice instead.

---

## Running Tests

```bash
# From Xcode
⌘U

# From the terminal
xcodebuild test \
  -project "ShortCuts For Beginners.xcodeproj" \
  -scheme "ShortCuts For Beginners" \
  -destination "platform=macOS"
```

The test suite (Swift Testing) covers:
- Every shortcut has a non-empty title, description, and key list
- All key labels are valid symbols recognized by Practice Mode
- Every category contains at least one shortcut
- Shortcuts within each category are sorted alphabetically
- No duplicate titles within a category

---

## Roadmap

- [ ] Progress tracking — mark shortcuts as learned, show completion per category
- [ ] Quiz Mode — app shows a shortcut name, you press the keys from memory
- [ ] Search — filter shortcuts by name across all categories
- [ ] Daily reminder — "shortcut of the day" via `UserNotifications`
- [ ] Favourites — star shortcuts and view them in a dedicated sidebar section
- [ ] Per-app categories — Xcode, Pages, Excel shortcuts
- [ ] iCloud sync + iPad support

---

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-new-shortcuts`
3. Add shortcuts or improvements to the relevant file
4. Run **⌘U** to make sure all tests pass
5. Open a Pull Request

---

## License

MIT — see [LICENSE](LICENSE) for details.
