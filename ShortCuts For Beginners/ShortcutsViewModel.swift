//
//  ShortcutsViewModel.swift
//  ShortCuts For Beginners
//
//  A small view model that owns the shortcut data and answers
//  simple questions for the views (MVVM).
//

import Foundation
import Observation

@Observable
final class ShortcutsViewModel {

    /// All shortcuts in the app. Loaded once from the developer data.
    let shortcuts: [ShortcutItem]

    init(shortcuts: [ShortcutItem] = ShortcutItem.sampleData) {
        self.shortcuts = shortcuts
    }

    /// All categories that actually contain at least one shortcut,
    /// in the order they are declared.
    var categories: [ShortcutCategory] {
        ShortcutCategory.allCases.filter { category in
            shortcuts.contains { $0.category == category }
        }
    }

    /// The shortcuts belonging to one category, sorted alphabetically.
    func shortcuts(in category: ShortcutCategory) -> [ShortcutItem] {
        shortcuts
            .filter { $0.category == category }
            .sorted { $0.title < $1.title }
    }
}
