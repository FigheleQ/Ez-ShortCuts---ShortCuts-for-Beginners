# Developer Guide — ShortCuts For Beginners

Mid-level developer reference: architecture, how the code is wired together,
and how to extend it without breaking things.

---

## Architecture Overview

The app follows a lightweight **MVVM** pattern using SwiftUI and Swift's native
`@Observable` macro (no Combine, no UIKit).

```
ShortcutItem          ←  pure data (structs + enum)
ShortcutsViewModel    ←  @Observable class; owns & filters the data
ContentView           ←  root NavigationSplitView; owns state
ShortcutDetailView    ←  reads one ShortcutItem; owns Practice Mode state
KeyCapView            ←  pure presentational component
```

State flows one way: ViewModel → View. No view ever writes back to the model.

---

## File-by-file Breakdown

### `ShortcutItem.swift`

The entire data layer lives here.

```swift
struct ShortcutItem: Identifiable, Hashable { ... }
```

Key fields:
- `keys: [String]` — the key caps in press order, e.g. `["⌘", "⇧", "4"]`.
  Use the Unicode modifier symbols (⌘ ⌥ ⇧ ⌃), not spelled-out words.
- `isSystemCaptured: Bool` — `true` for shortcuts macOS intercepts before any
  app can receive them (Spotlight, screenshot shortcuts, ⌘⇥…).
  Practice Mode uses this flag to decide whether to offer real-keyboard practice.
- `videoURL: URL?` — `nil` renders a placeholder card automatically.

All shortcuts live in the `sampleData` static array inside an extension.
Six categories are defined in `ShortcutCategory` (a `CaseIterable` enum so the
sidebar order is always deterministic).

---

### `ShortcutsViewModel.swift`

```swift
@Observable
final class ShortcutsViewModel { ... }
```

`@Observable` (Swift 5.9+) replaces `ObservableObject`/`@Published`. Any view
that reads a property from this class automatically re-renders when that
property changes — no explicit `@Published` annotations needed.

Two computed properties do all the work:
- `categories` — filters `ShortcutCategory.allCases` to only those that have
  at least one shortcut. Add a new category to the enum and it appears in the
  sidebar automatically once it has data.
- `shortcuts(in:)` — filters + sorts alphabetically. Sorting happens here, not
  in the data layer, so `sampleData` can stay in logical (not alphabetical) order.

---

### `ContentView.swift`

The root view owns two pieces of selection state:

```swift
@State private var selectedCategory: ShortcutCategory?
@State private var selectedShortcutID: ShortcutItem.ID?
```

`NavigationSplitView` wires the three columns:
1. **Sidebar** — `List` over `viewModel.categories` bound to `selectedCategory`
2. **Content** — `List` over `viewModel.shortcuts(in: selectedCategory)` bound
   to `selectedShortcutID`
3. **Detail** — resolves the full `ShortcutItem` from the ID and renders
   `ShortcutDetailView`

The ID-based selection (rather than storing the whole struct) avoids stale
references if the data ever changes at runtime.

`ShortcutRowView` is a small private struct in the same file — it's
presentation-only and has no state of its own.

---

### `ShortcutDetailView.swift`

Three visual sections, each in a `GroupBox`:

1. **Header** — title, category label, description
2. **Shortcut card** — `KeyCapRow` showing all keys statically
3. **PracticeModeView** — interactive (see below)
4. **VideoTutorialCard** — wraps `AVPlayer` / placeholder

#### `PracticeModeView` — how Practice Mode works

Two independent practice paths share the same `isComplete` / `pressedCount` state:

**Tap path (always available)**
```swift
Button { press(keyAt: index) } label: { KeyCapView(...) }
```
`press(keyAt:)` enforces in-order tapping: pressing key N when N−1 hasn't been
pressed resets the counter and fires a "nope" haptic.

**Real-keyboard path (only when `!isSystemCaptured` and one trigger key)**

Activated by a "Try It on Your Real Keyboard" button. Calls:
```swift
NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .flagsChanged]) { ... }
```
- `flagsChanged` events update `heldModifiers` — this highlights the modifier
  key caps on screen in real time as the user holds them down.
- `keyDown` events compare the held modifier flags and the typed character
  against the shortcut's `keys` array.
- The monitor returns `nil` (swallowing the event) so shortcuts like ⌘Q won't
  quit the app mid-practice.
- Escape always exits listening mode (unless Escape is the shortcut itself).

`matches(_:key:)` handles edge cases: special key codes (Space, arrows, Tab…)
are looked up by `keyCode`; the `+` key maps to both `+` and `=` since they
share a physical key on most layouts.

`stopListening()` is called on `onDisappear`, on `reset()`, and on success —
so the monitor is never left dangling.

---

### `KeyCapView.swift`

Purely presentational. Takes `key: String` and `isPressed: Bool`:

```swift
KeyCapView(key: "⌘", isPressed: true)
```

`isPressed` drives the fill colour (accent) and a `scaleEffect(0.92)` with a
`.spring` animation. This is the only animation in the component — Practice
Mode drives it by passing `index < pressedCount` or `heldModifiers.contains(key)`.

`KeyCapRow` is a thin wrapper that lays out multiple `KeyCapView`s with `+`
separators between them.

---

## Adding a New Shortcut

Open `ShortcutItem.swift`, find the relevant `// MARK:` section, and append:

```swift
ShortcutItem(
    title: "Select Word",
    description: "Double-click selects a word; this shortcut does the same from the keyboard.",
    keys: ["⌥", "⇧", "→"],
    category: .textEditing
)
```

That's it — the sidebar count, list, and detail view update automatically.

**Flag system shortcuts:**

```swift
isSystemCaptured: true   // macOS grabs this before the app can see it
```

**Attach a video:**

```swift
// Bundled — drag the file into the Xcode project first:
videoURL: ShortcutItem.localVideo(named: "SelectWordTutorial")

// Remote:
videoURL: URL(string: "https://cdn.example.com/select-word.mp4")
// Also requires App Sandbox → Outgoing Connections (Client) in Xcode capabilities.
```

---

## Adding a New Category

1. Add a case to `ShortcutCategory` in `ShortcutItem.swift`:
   ```swift
   case accessibility = "Accessibility"
   ```
2. Add `symbolName` and `subtitle` for the new case in the `switch` statements.
3. Add `ShortcutItem`s with `category: .accessibility` to `sampleData`.

The sidebar, filters, and view model pick it up with zero further changes.

---

## Tests

Tests live in `ShortCuts_For_BeginnersTests.swift` and use **Swift Testing**
(`import Testing`, `@Test`, `#expect`).

Run with **⌘U** in Xcode or:
```bash
xcodebuild test \
  -project "ShortCuts For Beginners.xcodeproj" \
  -scheme "ShortCuts For Beginners" \
  -destination "platform=macOS"
```

Current coverage:
- `everyShortcutHasTitleDescriptionAndKeys` — data completeness
- `everyKeyLabelIsValid` — catches typos in key symbols
- `everyCategoryContainsAtLeastOneShortcut` — ViewModel categories match enum
- `shortcutsInCategoryAreSortedAlphabetically` — ViewModel sort contract
- `titlesAreUniqueWithinEachCategory` — no accidental duplicates

When you add shortcuts, run tests to catch symbol typos before they reach
Practice Mode's key-matching logic.

---

## Common Pitfalls

| Mistake | Effect | Fix |
|---|---|---|
| Using `"Command"` instead of `"⌘"` in `keys` | Key cap renders the word, Practice Mode can't match it | Always use the Unicode symbol |
| Forgetting `isSystemCaptured: true` on e.g. ⌘⇧3 | Real-keyboard listener never fires, no feedback | Add the flag |
| Leaving `keyMonitor` alive on view dismiss | Monitor leaks, can intercept shortcuts in other views | Already handled by `onDisappear` — don't remove it |
| Adding a category without `symbolName` / `subtitle` | Compiler error (non-exhaustive switch) | Fill in both switch cases |

---

## Minimum Deployment Target

macOS 14 (Sonoma). The code uses:
- `@Observable` — macOS 14+
- `ContentUnavailableView` — macOS 14+
- `.symbolEffect` — macOS 14+
- `NavigationSplitView` — macOS 13+ (but `@Observable` raises the floor to 14)
