//
//  ColorSplashViewModel.swift
//  136KexmexcregrexPrellil
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class ColorSplashViewModel: ObservableObject {
    enum SlotStyle: String, CaseIterable {
        case tile
        case ring
        case diamond
    }

    struct Swatch: Identifiable, Equatable {
        let id = UUID()
        let color: Color
        let paletteIndex: Int
    }

    struct TargetSlot: Identifiable, Equatable {
        let id = UUID()
        let color: Color
        let paletteIndex: Int
        var filled: Bool
        let style: SlotStyle
        let isDecoy: Bool
    }

    enum Phase: Equatable {
        case ready
        case playing
        case finished(win: Bool)
    }

    let difficulty: Difficulty
    let level: Int

    @Published private(set) var phase: Phase = .ready
    @Published private(set) var targets: [TargetSlot] = []
    @Published private(set) var swatches: [Swatch] = []
    @Published private(set) var lives: Int = 3
    @Published private(set) var secondsRemaining: Double = 0
    @Published private(set) var sessionBudget: Double = 1
    /// Total time budget at start (for UI gauges); bonus adds to remaining time separately.
    @Published private(set) var initialSessionTime: Double = 1
    @Published private(set) var mistakes: Int = 0
    @Published private(set) var roundsCompleted: Int = 0
    @Published private(set) var totalRounds: Int = 0
    @Published private(set) var comboStreak: Int = 0
    @Published private(set) var lastMatchFlashIndex: Int?
    @Published private(set) var bonusSecondsEarned: Double = 0

    private var timerCancellable: AnyCancellable?
    private let startDate = Date()
    private var initialTime: Double = 1

    init(difficulty: Difficulty, level: Int) {
        self.difficulty = difficulty
        self.level = level
    }

    func startSession() {
        totalRounds = 4 + min(2, max(0, level - 1))
        lives = 3
        mistakes = 0
        roundsCompleted = 0
        comboStreak = 0
        bonusSecondsEarned = 0
        lastMatchFlashIndex = nil
        initialTime = baseTime()
        initialSessionTime = initialTime
        sessionBudget = initialTime
        secondsRemaining = initialTime
        phase = .playing
        buildRound()
        timerCancellable?.cancel()
        timerCancellable = Timer.publish(every: 0.2, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    func cancelTimers() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    func attemptDrop(swatchID: UUID, targetIndex: Int) {
        guard case .playing = phase else { return }
        guard swatches.contains(where: { $0.id == swatchID }) else { return }
        guard targets.indices.contains(targetIndex) else { return }
        guard !targets[targetIndex].filled else { return }

        if targets[targetIndex].isDecoy {
            registerMiss()
            return
        }

        guard let swatch = swatches.first(where: { $0.id == swatchID }) else { return }
        if swatch.paletteIndex == targets[targetIndex].paletteIndex {
            targets[targetIndex].filled = true
            swatches.removeAll { $0.id == swatch.id }
            comboStreak += 1
            lastMatchFlashIndex = targetIndex
            applyComboTimeBonus()
            if targets.filter({ !$0.isDecoy }).allSatisfy(\.filled) {
                roundsCompleted += 1
                lastMatchFlashIndex = nil
                if roundsCompleted >= totalRounds {
                    finish(win: true)
                } else {
                    buildRound()
                }
            }
        } else {
            registerMiss()
        }
    }

    func clearMatchFlash() {
        lastMatchFlashIndex = nil
    }

    private func registerMiss() {
        mistakes += 1
        comboStreak = 0
        lastMatchFlashIndex = nil
        lives = max(0, lives - 1)
        if lives == 0 {
            finish(win: false)
        }
    }

    private func applyComboTimeBonus() {
        guard comboStreak > 0, comboStreak % 3 == 0 else { return }
        let gain = min(2.4, initialTime * 0.08)
        secondsRemaining += gain
        bonusSecondsEarned += gain
    }

    func summary() -> (Bool, Int, Double, Double) {
        let duration = Date().timeIntervalSince(startDate)
        let won: Bool
        if case let .finished(win) = phase {
            won = win
        } else {
            won = false
        }
        let stars = starRating(won: won)
        let totalMoves = max(1, mistakes + roundsCompleted * max(1, paletteSize()))
        let accuracy = max(0, min(100, 100 - Double(mistakes) / Double(totalMoves) * 100))
        return (won, stars, duration, accuracy)
    }

    private func finish(win: Bool) {
        timerCancellable?.cancel()
        timerCancellable = nil
        phase = .finished(win: win)
    }

    private func tick() {
        guard case .playing = phase else { return }
        secondsRemaining -= 0.2
        if secondsRemaining <= 0 {
            secondsRemaining = 0
            finish(win: false)
        }
    }

    private func baseTime() -> Double {
        let base: Double
        switch difficulty {
        case .easy: base = 48
        case .normal: base = 38
        case .hard: base = 30
        }
        let trimmed = base - Double(level - 1) * 1.8
        return max(14, trimmed)
    }

    private func paletteSize() -> Int {
        switch difficulty {
        case .easy: return 3
        case .normal: return 4
        case .hard: return 5
        }
    }

    private func buildPalette(count: Int) -> [Color] {
        let pool: [Color] = [
            Color.appPrimary,
            Color.appAccent,
            Color.appSurface,
            Color.appPrimary.opacity(0.7),
            Color.appAccent.opacity(0.55),
            Color.appSurface.opacity(0.9),
            Color.appAccent.opacity(0.82),
        ]
        return Array(pool.prefix(count))
    }

    private func styleForColumn(_ index: Int) -> SlotStyle {
        let styles = SlotStyle.allCases
        return styles[index % styles.count]
    }

    private func buildRound() {
        let count = paletteSize()
        let palette = buildPalette(count: count)
        var built: [TargetSlot] = (0 ..< count).map { idx in
            TargetSlot(
                color: palette[idx],
                paletteIndex: idx,
                filled: false,
                style: styleForColumn(idx),
                isDecoy: false
            )
        }
        built.shuffle()

        if difficulty == .hard {
            let decoySlot = TargetSlot(
                color: Color.appSurface.opacity(0.55),
                paletteIndex: -1,
                filled: false,
                style: .ring,
                isDecoy: true
            )
            let insertAt = Int.random(in: 0 ... built.count)
            built.insert(decoySlot, at: insertAt)
        }

        targets = built
        swatches = (0 ..< count).map { idx in
            Swatch(color: palette[idx], paletteIndex: idx)
        }
        .shuffled()
    }

    private func starRating(won: Bool) -> Int {
        guard won else { return 0 }
        var score = 1
        if mistakes == 0 { score += 1 }
        let ratio = secondsRemaining / max(1, initialTime + bonusSecondsEarned)
        if ratio > 0.22 { score += 1 }
        return min(3, score)
    }
}

