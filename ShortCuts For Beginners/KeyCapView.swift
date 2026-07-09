//
//  KeyCapView.swift
//  ShortCuts For Beginners
//
//  A single keyboard key cap styled to resemble a physical key,
//  plus a row view that lays out a whole shortcut like [⌘] + [Space].
//

import SwiftUI

// MARK: - Single Key Cap

struct KeyCapView: View {
    let key: String
    /// Highlighted state used by Practice Mode.
    var isPressed: Bool = false

    var body: some View {
        Text(key)
            .font(.system(size: 20, weight: .medium, design: .rounded))
            .foregroundStyle(isPressed ? Color.white : Color.primary)
            .frame(minWidth: 44)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(isPressed ? AnyShapeStyle(Color.accentColor)
                                    : AnyShapeStyle(.background))
                    .shadow(color: .black.opacity(0.25), radius: 1, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(.quaternary, lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.92 : 1.0)
            .animation(.spring(duration: 0.2), value: isPressed)
    }
}

// MARK: - Key Row  (e.g. [⌘] + [Space])

struct KeyCapRow: View {
    let keys: [String]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(Array(keys.enumerated()), id: \.offset) { index, key in
                if index > 0 {
                    Text("+")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                KeyCapView(key: key)
            }
        }
    }
}

#Preview("Key Caps") {
    VStack(spacing: 20) {
        KeyCapRow(keys: ["⌘", "Space"])
        KeyCapRow(keys: ["⌘", "⇧", "4"])
        KeyCapView(key: "⌘", isPressed: true)
    }
    .padding(40)
}
