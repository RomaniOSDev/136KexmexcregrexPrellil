//
//  Difficulty.swift
//  136KexmexcregrexPrellil
//

import Foundation

enum Difficulty: String, CaseIterable, Identifiable, Hashable, Codable {
    case easy
    case normal
    case hard

    var id: String { rawValue }

    var displayTitle: String {
        switch self {
        case .easy: return "Easy"
        case .normal: return "Normal"
        case .hard: return "Hard"
        }
    }
}
