//
//  LevelPresentation.swift
//  136KexmexcregrexPrellil
//

import Foundation

enum LevelChapter: Int, CaseIterable, Identifiable {
    case shallows
    case midChannel
    case highCrest

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .shallows: return "Tidal Shallows"
        case .midChannel: return "Mid Channel"
        case .highCrest: return "High Crest"
        }
    }

    var blurb: String {
        switch self {
        case .shallows: return "Gentle introductions—learn the rhythm of this activity."
        case .midChannel: return "Complexity climbs; expect quicker decisions."
        case .highCrest: return "Maximum pressure—only refined runs survive."
        }
    }

    var levelRange: ClosedRange<Int> {
        switch self {
        case .shallows: return 1 ... 5
        case .midChannel: return 6 ... 10
        case .highCrest: return 11 ... 15
        }
    }

    var rangeLabel: String {
        let lo = levelRange.lowerBound
        let hi = levelRange.upperBound
        return String(format: "%02d–%02d", lo, hi)
    }

    static func chapter(containing level: Int) -> LevelChapter {
        if LevelChapter.shallows.levelRange.contains(level) { return .shallows }
        if LevelChapter.midChannel.levelRange.contains(level) { return .midChannel }
        return .highCrest
    }
}

enum LevelPresentation {
    static func stageTitle(activity: ActivityKind, level: Int) -> String {
        let idx = max(0, min(14, level - 1))
        switch activity {
        case .colorSplash:
            return colorTitles[idx]
        case .shapeShift:
            return shapeTitles[idx]
        case .rhythmTap:
            return rhythmTitles[idx]
        }
    }

    static func stageOrdinal(_ level: Int) -> String {
        String(format: "%02d", level)
    }

    private static let colorTitles: [String] = [
        "Solo Hue",
        "Tandem Drift",
        "Triple Dock",
        "Crosswake",
        "Harbor Mix",
        "Depth Course",
        "Prism Run",
        "Surge Stack",
        "Tide Lock",
        "Current Web",
        "Storm Palette",
        "Aurora Chain",
        "Spectrum Weave",
        "Luminous Coil",
        "Master Stroke",
    ]

    private static let shapeTitles: [String] = [
        "Soft Fit",
        "Corner Glide",
        "Diamond Drift",
        "Silhouette Four",
        "Echo Mold",
        "Rotation Run",
        "Scale Bridge",
        "Offset Path",
        "Precision Lock",
        "Complex Trace",
        "Veil Cut",
        "Apex Align",
        "Spiral Match",
        "Final Forge",
        "Shape Crown",
    ]

    private static let rhythmTitles: [String] = [
        "Warm Pulse",
        "Beat Pair",
        "Triplet Line",
        "Offstep One",
        "Cadence Five",
        "Half Glide",
        "Sync Bridge",
        "Rush Layer",
        "Tension Tap",
        "Steady Bloom",
        "Ghost Step",
        "Velocity Peak",
        "Polyrhythm",
        "Finale Strike",
        "Tempo Crown",
    ]
}
