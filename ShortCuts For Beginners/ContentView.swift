//
//  ContentView.swift
//  ShortCuts For Beginners
//
//  The main dashboard: a native macOS split view with categories in the
//  sidebar, the shortcuts of the selected category in the middle column,
//  and the interactive learning view on the right.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = ShortcutsViewModel()
    @State private var selectedCategory: ShortcutCategory? = .systemEssentials
    // List selection must match the data's `id` type, so we store the id.
    @State private var selectedShortcutID: ShortcutItem.ID?

    var body: some View {
        NavigationSplitView {
            sidebar
        } content: {
            shortcutList
        } detail: {
            detail
        }
        .frame(minWidth: 900, minHeight: 560)
    }

    // MARK: Sidebar (Categories)

    private var sidebar: some View {
        List(viewModel.categories, selection: $selectedCategory) { category in
            Label(category.rawValue, systemImage: category.symbolName)
        }
        .navigationTitle("Shortcuts")
        .navigationSplitViewColumnWidth(min: 200, ideal: 220)
    }

    // MARK: Shortcut List (Middle Column)

    @ViewBuilder
    private var shortcutList: some View {
        if let category = selectedCategory {
            List(viewModel.shortcuts(in: category), selection: $selectedShortcutID) { shortcut in
                ShortcutRowView(shortcut: shortcut)
            }
            .navigationTitle(category.rawValue)
            .navigationSubtitle(category.subtitle)
            .navigationSplitViewColumnWidth(min: 260, ideal: 300)
        } else {
            ContentUnavailableView(
                "Select a Category",
                systemImage: "sidebar.left",
                description: Text("Choose a category from the sidebar to see its shortcuts.")
            )
        }
    }

    // MARK: Detail

    @ViewBuilder
    private var detail: some View {
        if let shortcut = viewModel.shortcuts.first(where: { $0.id == selectedShortcutID }) {
            ShortcutDetailView(shortcut: shortcut)
        } else {
            ContentUnavailableView(
                "Select a Shortcut",
                systemImage: "keyboard",
                description: Text("Pick a shortcut from the list to learn and practice it.")
            )
        }
    }
}

// MARK: - List Row

struct ShortcutRowView: View {
    let shortcut: ShortcutItem

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(shortcut.title)
                    .font(.body)
                Text(shortcut.keys.joined(separator: " "))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if shortcut.videoURL != nil {
                Image(systemName: "play.rectangle.fill")
                    .foregroundStyle(.secondary)
                    .help("Includes a video tutorial")
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    ContentView()
        .frame(width: 1000, height: 640)
}
