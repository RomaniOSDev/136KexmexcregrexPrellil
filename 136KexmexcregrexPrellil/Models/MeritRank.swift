//
//  MeritRank.swift
//  136KexmexcregrexPrellil
//

import Foundation

enum MeritRank: Int, CaseIterable, Comparable {
    case novice = 0
    case aspirant
    case specialist
    case virtuoso
    case champion
    case luminary

    static func < (lhs: MeritRank, rhs: MeritRank) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var minStarsRequired: Int {
        switch self {
        case .novice: return 0
        case .aspirant: return 8
        case .specialist: return 22
        case .virtuoso: return 45
        case .champion: return 72
        case .luminary: return 105
        }
    }

    var displayTitle: String {
        switch self {
        case .novice: return "Novice"
        case .aspirant: return "Aspirant"
        case .specialist: return "Specialist"
        case .virtuoso: return "Virtuoso"
        case .champion: return "Champion"
        case .luminary: return "Luminary"
        }
    }

    var tagline: String {
        switch self {
        case .novice: return "Take the first steps across every activity."
        case .aspirant: return "Form a steady rhythm of clears."
        case .specialist: return "Turn patterns into instinct."
        case .virtuoso: return "Chase polish on tougher tiers."
        case .champion: return "Near-complete mastery—few stars left."
        case .luminary: return "Peak performance across the board."
        }
    }

    static func rank(forTotalStars total: Int) -> MeritRank {
        allCases
            .filter { total >= $0.minStarsRequired }
            .max(by: { $0.rawValue < $1.rawValue }) ?? .novice
    }

    func next() -> MeritRank? {
        MeritRank(rawValue: rawValue + 1)
    }
}

struct MeritProgress {
    let rank: MeritRank
    let totalStars: Int
    /// 0...1 toward next rank; 1 if at max.
    let fractionToNext: Double
    let starsToNextRank: Int?
}
