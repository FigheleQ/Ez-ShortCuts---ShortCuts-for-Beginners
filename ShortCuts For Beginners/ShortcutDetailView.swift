//
//  ShortcutDetailView.swift
//  ShortCuts For Beginners
//
//  The interactive learning view: shortcut info, styled key caps,
//  a tap-to-practice mode with haptic feedback, and a video tutorial card.
//

import SwiftUI
import AVKit
import AppKit

struct ShortcutDetailView: View {
    let shortcut: ShortcutItem

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                shortcutCard
                PracticeModeView(shortcut: shortcut)
                VideoTutorialCard(videoURL: shortcut.videoURL)
            }
            .padding(24)
            .frame(maxWidth: 560, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle(shortcut.title)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    // MARK: Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(shortcut.category.rawValue, systemImage: shortcut.category.symbolName)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)

            Text(shortcut.title)
                .font(.largeTitle.bold())

            Text(shortcut.description)
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: Shortcut Display

    private var shortcutCard: some View {
        GroupBox {
            KeyCapRow(keys: shortcut.keys)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
        } label: {
            Label("The Shortcut", systemImage: "keyboard")
        }
    }
}

// MARK: - Practice Mode

/// The user can tap the on-screen keys in order, or press the real
/// shortcut on their keyboard. When the shortcut is completed, a success
/// animation plays with haptic feedback.
struct PracticeModeView: View {
    let shortcut: ShortcutItem

    /// How many keys have been correctly pressed so far (tap practice).
    @State private var pressedCount = 0
    @State private var isComplete = false

    // Real-keyboard practice.
    @State private var isListening = false
    @State private var heldModifiers: Set<String> = []
    @State private var showWrongKeyHint = false
    @State private var keyMonitor: Any?

    var body: some View {
        GroupBox {
            VStack(spacing: 16) {
                Text(statusMessage)
                    .font(.callout)
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    ForEach(Array(shortcut.keys.enumerated()), id: \.offset) { index, key in
                        if index > 0 {
                            Text("+")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                        }
                        Button {
                            press(keyAt: index)
                        } label: {
                            KeyCapView(key: key,
                                       isPressed: index < pressedCount
                                                  || (isListening && heldModifiers.contains(key)))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Press \(key) key")
                    }
                }
                .padding(.vertical, 8)

                if isComplete {
                    successBadge
                } else {
                    Text("\(pressedCount) of \(shortcut.keys.count) keys pressed")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .monospacedDigit()

                    realKeyboardControls
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        } label: {
            Label("Practice Mode", systemImage: "hand.tap")
        }
        // Start fresh whenever the user opens a different shortcut.
        .onChange(of: shortcut.id) { reset() }
        .onDisappear { stopListening() }
    }

    private var statusMessage: String {
        if isComplete {
            "Great job! You've mastered this shortcut."
        } else if isListening {
            "Go ahead — press \(shortcut.keys.joined(separator: " ")) on your keyboard."
        } else {
            "Tap the keys in order, just like on a real keyboard."
        }
    }

    // MARK: Real Keyboard Practice

    /// Controls for practicing with the physical keyboard. Shortcuts that
    /// macOS intercepts system-wide can only be practiced by tapping.
    @ViewBuilder
    private var realKeyboardControls: some View {
        if supportsRealKeyboard {
            if isListening {
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "ear.badge.waveform")
                            .foregroundStyle(Color.accentColor)
                            .symbolEffect(.variableColor.iterative, isActive: isListening)
                        Text("Listening to your keyboard…")
                            .font(.callout)
                        Button("Stop") { stopListening() }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                    }

                    if showWrongKeyHint {
                        Text("Not quite — check the keys above and try again.")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
                .transition(.opacity)
            } else {
                Button {
                    startListening()
                } label: {
                    Label("Try It on Your Real Keyboard", systemImage: "keyboard")
                }
                .buttonStyle(.bordered)
            }
        } else {
            Text("macOS reserves this shortcut for the system, so the app can't detect it. Practice by tapping the keys above.")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
    }

    private var successBadge: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title)
                .foregroundStyle(.green)
                .symbolEffect(.bounce, value: isComplete)

            Text("Shortcut completed!")
                .font(.headline)

            Button("Try Again") { reset() }
                .buttonStyle(.bordered)
        }
        .transition(.scale.combined(with: .opacity))
    }

    // MARK: Practice Logic

    private func press(keyAt index: Int) {
        guard !isComplete else { return }

        if index == pressedCount {
            // Correct key: advance and give a light haptic tick.
            pressedCount += 1
            performHaptic(.levelChange)

            if pressedCount == shortcut.keys.count {
                complete()
            }
        } else if index > pressedCount {
            // Wrong order: gentle "nope" feedback and start over.
            performHaptic(.generic)
            pressedCount = 0
        }
    }

    private func complete() {
        pressedCount = shortcut.keys.count
        withAnimation(.bouncy) { isComplete = true }
        performHaptic(.alignment)
        stopListening()
    }

    private func reset() {
        stopListening()
        withAnimation(.snappy) {
            pressedCount = 0
            isComplete = false
        }
    }

    // MARK: Key Event Matching

    private static let modifierSymbols: Set<String> = ["⌘", "⇧", "⌥", "⌃"]

    /// Keys that aren't identified by the characters they type.
    private static let specialKeyCodes: [String: UInt16] = [
        "Space": 49, "⇥": 48, "⎋": 53, "⌫": 51, "↩": 36,
        "←": 123, "→": 124, "↓": 125, "↑": 126, "`": 50
    ]

    /// The non-modifier keys of the shortcut (usually exactly one).
    private var triggerKeys: [String] {
        shortcut.keys.filter { !Self.modifierSymbols.contains($0) }
    }

    /// Real-keyboard practice needs a shortcut the app can actually
    /// receive: not system-captured, and a single trigger key.
    private var supportsRealKeyboard: Bool {
        !shortcut.isSystemCaptured && triggerKeys.count == 1
    }

    private func modifierFlag(for symbol: String) -> NSEvent.ModifierFlags? {
        switch symbol {
        case "⌘": return .command
        case "⇧": return .shift
        case "⌥": return .option
        case "⌃": return .control
        default: return nil
        }
    }

    private func matches(_ event: NSEvent, key: String) -> Bool {
        if let code = Self.specialKeyCodes[key] {
            return event.keyCode == code
        }
        guard let typed = event.charactersIgnoringModifiers?.lowercased() else { return false }
        // "⌘ +" is physically the "=" key on most layouts.
        if key == "+" { return typed == "+" || typed == "=" }
        return typed == key.lowercased()
    }

    private func startListening() {
        guard keyMonitor == nil else { return }
        withAnimation(.snappy) {
            isListening = true
            showWrongKeyHint = false
            pressedCount = 0
        }
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .flagsChanged]) { event in
            handleKeyEvent(event)
        }
    }

    private func stopListening() {
        if let keyMonitor { NSEvent.removeMonitor(keyMonitor) }
        keyMonitor = nil
        withAnimation(.snappy) {
            isListening = false
            heldModifiers = []
            showWrongKeyHint = false
        }
    }

    /// Handles one keyboard event while listening. Returning `nil`
    /// swallows the event so shortcuts like ⌘Q or ⌘W don't trigger
    /// their normal actions during practice.
    private func handleKeyEvent(_ event: NSEvent) -> NSEvent? {
        guard isListening else { return event }

        if event.type == .flagsChanged {
            // Light up the modifier key caps the user is holding down.
            let held = Self.modifierSymbols.filter { symbol in
                guard let flag = modifierFlag(for: symbol) else { return false }
                return event.modifierFlags.contains(flag)
            }
            heldModifiers = held.intersection(Set(shortcut.keys))
            return event
        }

        guard !event.isARepeat, let trigger = triggerKeys.first else { return nil }

        // Escape exits listening mode (unless Escape is the shortcut itself).
        if event.keyCode == 53, trigger != "⎋" {
            stopListening()
            return nil
        }

        let required = shortcut.keys
            .compactMap(modifierFlag(for:))
            .reduce(into: NSEvent.ModifierFlags()) { $0.insert($1) }
        let held = event.modifierFlags.intersection([.command, .shift, .option, .control])

        if held == required && matches(event, key: trigger) {
            complete()
        } else {
            performHaptic(.generic)
            withAnimation(.snappy) { showWrongKeyHint = true }
        }
        return nil
    }

    /// Haptic feedback on Macs with a Force Touch trackpad.
    /// On other Macs this is silently ignored — exactly what we want.
    private func performHaptic(_ pattern: NSHapticFeedbackManager.FeedbackPattern) {
        NSHapticFeedbackManager.defaultPerformer.perform(pattern, performanceTime: .now)
    }
}

// MARK: - Video Tutorial Card

/// A native video preview card. Shows a `VideoPlayer` when the shortcut
/// has a video, and a friendly placeholder when it doesn't.
struct VideoTutorialCard: View {
    let videoURL: URL?

    @State private var player: AVPlayer?

    var body: some View {
        GroupBox {
            Group {
                if videoURL != nil {
                    VideoPlayer(player: player)
                        .aspectRatio(16 / 9, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                } else {
                    placeholder
                }
            }
            .padding(.vertical, 4)
        } label: {
            Label("Video Tutorial", systemImage: "play.rectangle")
        }
        .onAppear {
            if let videoURL {
                player = AVPlayer(url: videoURL)
            }
        }
        .onChange(of: videoURL) {
            player?.pause()
            player = videoURL.map { AVPlayer(url: $0) }
        }
        .onDisappear {
            player?.pause()
        }
    }

    private var placeholder: some View {
        VStack(spacing: 8) {
            Image(systemName: "video.slash")
                .font(.largeTitle)
                .foregroundStyle(.tertiary)
            Text("Video tutorial coming soon")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 160)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.quaternary.opacity(0.5))
        )
    }
}

#Preview("Detail") {
    NavigationStack {
        ShortcutDetailView(shortcut: ShortcutItem.sampleData[0])
    }
    .frame(width: 640, height: 800)
}
