//
//  AppStorage.swift
//  136KexmexcregrexPrellil
//

import Combine
import Foundation

extension Notification.Name {
    static let appProgressDidReset = Notification.Name("appProgressDidReset")
}

enum AchievementCategory: String, CaseIterable, Identifiable {
    case progress
    case mastery
    case dedication

    var id: String { rawValue }

    var displayTitle: String {
        switch self {
        case .progress: return "Progress"
        case .mastery: return "Mastery"
        case .dedication: return "Dedication"
        }
    }
}

struct AchievementRow: Identifiable, Equatable {
    let id: String
    let title: String
    let detail: String
    let isUnlocked: Bool
    let category: AchievementCategory
}

@MainActor
final class AppStorage: ObservableObject {
    static let shared = AppStorage()

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let hasSeenOnboarding = "progress.hasSeenOnboarding"
        static let totalPlaySeconds = "progress.totalPlaySeconds"
        static let sessionsFinished = "progress.sessionsFinished"
        static let totalWins = "progress.totalWins"
        static let winsColorSplash = "progress.wins.colorSplash"
        static let winsShapeShift = "progress.wins.shapeShift"
        static let winsRhythmTap = "progress.wins.rhythmTap"
        static let winsEasy = "progress.wins.easy"
        static let winsNormal = "progress.wins.normal"
        static let winsHard = "progress.wins.hard"
    }

    private static let levelCount = 15

    @Published private(set) var hasSeenOnboarding: Bool
    @Published private(set) var totalPlaySeconds: Double
    @Published private(set) var sessionsFinished: Int
    @Published private(set) var totalWins: Int
    @Published private(set) var winsColorSplash: Int
    @Published private(set) var winsShapeShift: Int
    @Published private(set) var winsRhythmTap: Int
    @Published private(set) var winsOnEasy: Int
    @Published private(set) var winsOnNormal: Int
    @Published private(set) var winsOnHard: Int

    private init() {
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        totalPlaySeconds = defaults.double(forKey: Keys.totalPlaySeconds)
        sessionsFinished = defaults.integer(forKey: Keys.sessionsFinished)
        totalWins = defaults.integer(forKey: Keys.totalWins)
        winsColorSplash = defaults.integer(forKey: Keys.winsColorSplash)
        winsShapeShift = defaults.integer(forKey: Keys.winsShapeShift)
        winsRhythmTap = defaults.integer(forKey: Keys.winsRhythmTap)
        winsOnEasy = defaults.integer(forKey: Keys.winsEasy)
        winsOnNormal = defaults.integer(forKey: Keys.winsNormal)
        winsOnHard = defaults.integer(forKey: Keys.winsHard)
    }

    static func levelCountValue() -> Int { levelCount }

    func markOnboardingFinished() {
        defaults.set(true, forKey: Keys.hasSeenOnboarding)
        hasSeenOnboarding = true
        objectWillChange.send()
    }

    func stars(activity: ActivityKind, difficulty: Difficulty, level: Int) -> Int {
        let key = Self.starsKey(activity: activity, difficulty: difficulty, level: level)
        return defaults.integer(forKey: key)
    }

    func isLevelUnlocked(activity: ActivityKind, difficulty: Difficulty, level: Int) -> Bool {
        if level <= 1 { return true }
        let key = Self.unlockedKey(activity: activity, difficulty: difficulty, level: level)
        if defaults.object(forKey: key) == nil {
            return false
        }
        return defaults.bool(forKey: key)
    }

    func allLevelsCleared(activity: ActivityKind, difficulty: Difficulty) -> Bool {
        (1 ... Self.levelCount).allSatisfy { idx in
            stars(activity: activity, difficulty: difficulty, level: idx) >= 1
        }
    }

    func anyLevelAvailable(activity: ActivityKind, difficulty: Difficulty) -> Bool {
        (1 ... Self.levelCount).contains { isLevelUnlocked(activity: activity, difficulty: difficulty, level: $0) }
    }

    func meritProgressSnapshot() -> MeritProgress {
        let total = totalStarsSum()
        let rank = MeritRank.rank(forTotalStars: total)
        guard let next = rank.next() else {
            return MeritProgress(rank: rank, totalStars: total, fractionToNext: 1, starsToNextRank: nil)
        }
        let span = Double(next.minStarsRequired - rank.minStarsRequired)
        let gained = Double(total - rank.minStarsRequired)
        let frac = span > 0 ? min(1, max(0, gained / span)) : 1
        let need = max(0, next.minStarsRequired - total)
        return MeritProgress(rank: rank, totalStars: total, fractionToNext: frac, starsToNextRank: need > 0 ? need : nil)
    }

    func unlockedAchievementCount() -> Int {
        achievementSnapshot().filter(\.isUnlocked).count
    }

    func totalStarsSum() -> Int {
        var sum = 0
        for activity in ActivityKind.allCases {
            for difficulty in Difficulty.allCases {
                for level in 1 ... Self.levelCount {
                    sum += stars(activity: activity, difficulty: difficulty, level: level)
                }
            }
        }
        return sum
    }

    private func hasAnyTripleStarRating() -> Bool {
        for activity in ActivityKind.allCases {
            for difficulty in Difficulty.allCases {
                for level in 1 ... Self.levelCount {
                    if stars(activity: activity, difficulty: difficulty, level: level) >= 3 {
                        return true
                    }
                }
            }
        }
        return false
    }

    func achievementSnapshot() -> [AchievementRow] {
        let triplePlay = winsColorSplash >= 1 && winsShapeShift >= 1 && winsRhythmTap >= 1
        let marathon = totalPlaySeconds >= 600
        let marathonLong = totalPlaySeconds >= 1_800
        let collector = totalStarsSum() >= 24
        let hoarder = totalStarsSum() >= 48
        let aurora = totalStarsSum() >= 90
        let triad = winsOnEasy >= 1 && winsOnNormal >= 1 && winsOnHard >= 1
        let veteranSessions = sessionsFinished >= 30
        let centurionSessions = sessionsFinished >= 60

        return [
            AchievementRow(
                id: "first_victory",
                title: "First Victory",
                detail: "Win any stage once.",
                isUnlocked: totalWins >= 1,
                category: .progress
            ),
            AchievementRow(
                id: "triple_play",
                title: "Triple Play",
                detail: "Win at least one stage in every activity.",
                isUnlocked: triplePlay,
                category: .progress
            ),
            AchievementRow(
                id: "triad_path",
                title: "Triad Path",
                detail: "Win on Easy, Normal, and Hard at least once each.",
                isUnlocked: triad,
                category: .progress
            ),
            AchievementRow(
                id: "ten_wins",
                title: "Double Digits",
                detail: "Reach ten total wins.",
                isUnlocked: totalWins >= 10,
                category: .progress
            ),
            AchievementRow(
                id: "star_spark",
                title: "Star Spark",
                detail: "Earn a three-star rating on any stage.",
                isUnlocked: hasAnyTripleStarRating(),
                category: .mastery
            ),
            AchievementRow(
                id: "constellation",
                title: "Constellation",
                detail: "Collect twenty-four stars overall.",
                isUnlocked: collector,
                category: .mastery
            ),
            AchievementRow(
                id: "star_hoarder",
                title: "Aurora Hoard",
                detail: "Collect forty-eight stars overall.",
                isUnlocked: hoarder,
                category: .mastery
            ),
            AchievementRow(
                id: "zenith",
                title: "Zenith Band",
                detail: "Collect ninety stars overall.",
                isUnlocked: aurora,
                category: .mastery
            ),
            AchievementRow(
                id: "steady_session",
                title: "Steady Session",
                detail: "Accumulate ten minutes of play time.",
                isUnlocked: marathon,
                category: .dedication
            ),
            AchievementRow(
                id: "deep_run",
                title: "Deep Run",
                detail: "Accumulate thirty minutes of play time.",
                isUnlocked: marathonLong,
                category: .dedication
            ),
            AchievementRow(
                id: "veteran",
                title: "Stage Veteran",
                detail: "Finish thirty sessions.",
                isUnlocked: veteranSessions,
                category: .dedication
            ),
            AchievementRow(
                id: "centurion_sessions",
                title: "Marathon Curious",
                detail: "Finish sixty sessions.",
                isUnlocked: centurionSessions,
                category: .dedication
            ),
        ]
    }

    func applySession(
        activity: ActivityKind,
        difficulty: Difficulty,
        level: Int,
        won: Bool,
        stars: Int,
        durationSeconds: Double,
        accuracyPercent: Double
    ) -> SessionOutcome {
        let before = Set(achievementSnapshot().filter(\.isUnlocked).map(\.id))

        totalPlaySeconds += max(0, durationSeconds)
        defaults.set(totalPlaySeconds, forKey: Keys.totalPlaySeconds)

        sessionsFinished += 1
        defaults.set(sessionsFinished, forKey: Keys.sessionsFinished)

        if won {
            totalWins += 1
            defaults.set(totalWins, forKey: Keys.totalWins)

            switch activity {
            case .colorSplash:
                winsColorSplash += 1
                defaults.set(winsColorSplash, forKey: Keys.winsColorSplash)
            case .shapeShift:
                winsShapeShift += 1
                defaults.set(winsShapeShift, forKey: Keys.winsShapeShift)
            case .rhythmTap:
                winsRhythmTap += 1
                defaults.set(winsRhythmTap, forKey: Keys.winsRhythmTap)
            }

            switch difficulty {
            case .easy:
                winsOnEasy += 1
                defaults.set(winsOnEasy, forKey: Keys.winsEasy)
            case .normal:
                winsOnNormal += 1
                defaults.set(winsOnNormal, forKey: Keys.winsNormal)
            case .hard:
                winsOnHard += 1
                defaults.set(winsOnHard, forKey: Keys.winsHard)
            }

            let starKey = Self.starsKey(activity: activity, difficulty: difficulty, level: level)
            let previousBest = defaults.integer(forKey: starKey)
            let clampedStars = min(3, max(0, stars))
            let nextBest = max(previousBest, clampedStars)
            defaults.set(nextBest, forKey: starKey)

            let nextLevel = level + 1
            if nextLevel <= Self.levelCount {
                let unlockKey = Self.unlockedKey(activity: activity, difficulty: difficulty, level: nextLevel)
                defaults.set(true, forKey: unlockKey)
            }
        }

        objectWillChange.send()

        let after = Set(achievementSnapshot().filter(\.isUnlocked).map(\.id))
        let fresh = after.subtracting(before)

        return SessionOutcome(
            won: won,
            stars: min(3, max(0, stars)),
            durationSeconds: durationSeconds,
            accuracyPercent: accuracyPercent,
            newlyUnlockedAchievementIDs: Array(fresh).sorted()
        )
    }

    func resetAllProgress() {
        let keys = defaults.dictionaryRepresentation().keys.filter { key in
            key.hasPrefix("progress.") || key.hasPrefix("lvl.")
        }
        keys.forEach { defaults.removeObject(forKey: $0) }

        hasSeenOnboarding = false
        totalPlaySeconds = 0
        sessionsFinished = 0
        totalWins = 0
        winsColorSplash = 0
        winsShapeShift = 0
        winsRhythmTap = 0
        winsOnEasy = 0
        winsOnNormal = 0
        winsOnHard = 0

        defaults.set(false, forKey: Keys.hasSeenOnboarding)
        defaults.set(0, forKey: Keys.totalPlaySeconds)
        defaults.set(0, forKey: Keys.sessionsFinished)
        defaults.set(0, forKey: Keys.totalWins)
        defaults.set(0, forKey: Keys.winsColorSplash)
        defaults.set(0, forKey: Keys.winsShapeShift)
        defaults.set(0, forKey: Keys.winsRhythmTap)
        defaults.set(0, forKey: Keys.winsEasy)
        defaults.set(0, forKey: Keys.winsNormal)
        defaults.set(0, forKey: Keys.winsHard)

        objectWillChange.send()
        NotificationCenter.default.post(name: .appProgressDidReset, object: nil)
    }

    private static func starsKey(activity: ActivityKind, difficulty: Difficulty, level: Int) -> String {
        "lvl.stars.\(activity.rawValue).\(difficulty.rawValue).\(level)"
    }

    private static func unlockedKey(activity: ActivityKind, difficulty: Difficulty, level: Int) -> String {
        "lvl.unlock.\(activity.rawValue).\(difficulty.rawValue).\(level)"
    }
}
