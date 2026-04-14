//
//  ActivityKind.swift
//  136KexmexcregrexPrellil
//

import Foundation

enum ActivityKind: String, CaseIterable, Identifiable, Hashable, Codable {
    case colorSplash
    case shapeShift
    case rhythmTap

    var id: String { rawValue }

    var displayTitle: String {
        switch self {
        case .colorSplash: return "Color Splash"
        case .shapeShift: return "Shape Shift"
        case .rhythmTap: return "Rhythm Tap"
        }
    }

    var shortBlurb: String {
        switch self {
        case .colorSplash:
            return "Frame styles, combo chains, bonus seconds—Hard adds a trap slot."
        case .shapeShift:
            return "Three outline families, pinch & twist, with a live fit gauge."
        case .rhythmTap:
            return "Beat lane, perfect taps, and combo streaks against the pulse."
        }
    }
}
