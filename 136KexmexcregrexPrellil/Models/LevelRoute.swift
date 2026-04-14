//
//  LevelRoute.swift
//  136KexmexcregrexPrellil
//

import Foundation

/// Pushed on the same `NavigationPath` as `ActivityKind` (single stack per tab — no nested `NavigationStack`).
enum LevelRoute: Hashable {
    case play(activity: ActivityKind, difficulty: Difficulty, level: Int)
    case result(activity: ActivityKind, difficulty: Difficulty, level: Int, outcome: SessionOutcome)
}
