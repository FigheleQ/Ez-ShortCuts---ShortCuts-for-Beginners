//
//  ShortCuts_For_BeginnersTests.swift
//  ShortCuts For BeginnersTests
//
//  Created by Pawel Piotrowski on 07/07/2026.
//

import Testing
@testable import ShortCuts_For_Beginners

struct ShortCuts_For_BeginnersTests {

    /// The key labels Practice Mode and KeyCapView know how to display
    /// and match against real keyboard events.
    private static let knownKeyLabels: Set<String> = [
        "⌘", "⇧", "⌥", "⌃",                       // modifiers
        "Space", "⇥", "⎋", "⌫", "↩",               // named keys
        "←", "→", "↑", "↓", "`",                    // navigation & misc
        "[", "]", "+", "-", ",", "."
    ]

    @Test func everyShortcutHasTitleDescriptionAndKeys() {
        for shortcut in ShortcutItem.sampleData {
            #expect(!shortcut.title.isEmpty)
            #expect(!shortcut.description.isEmpty)
            #expect(!shortcut.keys.isEmpty)
        }
    }

    @Test func everyKeyLabelIsValid() {
        for shortcut in ShortcutItem.sampleData {
            for key in shortcut.keys {
                let isSingleCharacter = key.count == 1 && key == key.uppercased()
                #expect(Self.knownKeyLabels.contains(key) || isSingleCharacter,
                        "Unexpected key label \"\(key)\" in \(shortcut.title)")
            }
        }
    }

    @Test func everyCategoryContainsAtLeastOneShortcut() {
        let viewModel = ShortcutsViewModel()
        #expect(viewModel.categories == ShortcutCategory.allCases)
    }

    @Test func shortcutsInCategoryAreSortedAlphabetically() {
        let viewModel = ShortcutsViewModel()
        for category in viewModel.categories {
            let titles = viewModel.shortcuts(in: category).map(\.title)
            #expect(titles == titles.sorted())
        }
    }

    @Test func titlesAreUniqueWithinEachCategory() {
        let viewModel = ShortcutsViewModel()
        for category in viewModel.categories {
            let titles = viewModel.shortcuts(in: category).map(\.title)
            #expect(Set(titles).count == titles.count,
                    "Duplicate shortcut titles in \(category.rawValue)")
        }
    }
}
