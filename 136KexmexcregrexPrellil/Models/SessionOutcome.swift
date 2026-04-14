//
//  SessionOutcome.swift
//  136KexmexcregrexPrellil
//

import Foundation

struct SessionOutcome: Equatable, Hashable {
    let won: Bool
    let stars: Int
    let durationSeconds: Double
    let accuracyPercent: Double
    let newlyUnlockedAchievementIDs: [String]
}
