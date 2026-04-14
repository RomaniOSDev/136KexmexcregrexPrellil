//
//  ShapeShiftViewModel.swift
//  136KexmexcregrexPrellil
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class ShapeShiftViewModel: ObservableObject {
    enum Phase: Equatable {
        case ready
        case playing
        case finished(win: Bool)
    }

    enum OutlineKind: Int, CaseIterable {
        case blob
        case kite
        case wedge
    }

    let difficulty: Difficulty
    let level: Int

    @Published private(set) var outlineKind: OutlineKind = .blob
    @Published private(set) var alignmentScore: Double = 0
    @Published private(set) var phase: Phase = .ready
    @Published private(set) var secondsRemaining: Double = 0
    @Published private(set) var sessionBudget: Double = 1
    @Published private(set) var lockAttempts: Int = 0
    @Published private(set) var targetRotation: Double = 0
    @Published private(set) var targetScale: CGFloat = 1
    @Published var userRotation: Double = 0
    @Published var userScale: CGFloat = 1
    @Published var userOffset: CGSize = .zero

    private var timerCancellable: AnyCancellable?
    private let startDate = Date()

    init(difficulty: Difficulty, level: Int) {
        self.difficulty = difficulty
        self.level = level
    }

    func startSession() {
        lockAttempts = 0
        let d = difficultyIndex()
        outlineKind = OutlineKind.allCases[(level + d * 2) % OutlineKind.allCases.count]
        sessionBudget = baseTime()
        secondsRemaining = sessionBudget
        userRotation = Double.random(in: -40 ... 40)
        userScale = CGFloat.random(in: 0.85 ... 1.15)
        userOffset = CGSize(
            width: CGFloat.random(in: -18 ... 18),
            height: CGFloat.random(in: -18 ... 18)
        )
        targetRotation = Double.random(in: -110 ... 110)
        let baseScale = CGFloat.random(in: 0.9 ... 1.12)
        targetScale = baseScale + CGFloat(level) * 0.01
        phase = .playing
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

    func refreshFitGauge() {
        guard case .playing = phase else { return }
        alignmentScore = computeAlignmentScore()
    }

    private func difficultyIndex() -> Int {
        switch difficulty {
        case .easy: return 0
        case .normal: return 1
        case .hard: return 2
        }
    }

    func lockPlacement() {
        guard case .playing = phase else { return }
        lockAttempts += 1
        if isAligned() {
            finish(win: true)
        } else {
            secondsRemaining = max(0, secondsRemaining - penaltySeconds())
            if secondsRemaining == 0 {
                finish(win: false)
            }
        }
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
        let accuracy = max(0, min(100, 100 - Double(lockAttempts - (won ? 1 : 0)) * 12))
        return (won, stars, duration, accuracy)
    }

    private func finish(win: Bool) {
        timerCancellable?.cancel()
        timerCancellable = nil
        phase = .finished(win: win)
    }

    private func tick() {
        guard case .playing = phase else { return }
        alignmentScore = computeAlignmentScore()
        secondsRemaining -= 0.2
        if secondsRemaining <= 0 {
            secondsRemaining = 0
            finish(win: false)
        }
    }

    private func computeAlignmentScore() -> Double {
        let da = abs(normalizedDegrees(userRotation - targetRotation)) / max(angleTolerance() * 2.8, 1)
        let ds = abs(userScale - targetScale) / max(scaleTolerance() * 2.8, CGFloat(0.01))
        let off = hypot(userOffset.width, userOffset.height) / max(offsetTolerance() * 2.8, 1)
        let stress = (da + Double(ds) + off) / 3
        return max(0, min(1, 1 - stress))
    }

    private func baseTime() -> Double {
        let base: Double
        switch difficulty {
        case .easy: base = 40
        case .normal: base = 32
        case .hard: base = 26
        }
        return max(14, base - Double(level - 1) * 1.4)
    }

    private func penaltySeconds() -> Double {
        switch difficulty {
        case .easy: return 3
        case .normal: return 4
        case .hard: return 5
        }
    }

    private func angleTolerance() -> Double {
        switch difficulty {
        case .easy: return 18
        case .normal: return 12
        case .hard: return 8
        }
    }

    private func scaleTolerance() -> CGFloat {
        switch difficulty {
        case .easy: return 0.12
        case .normal: return 0.08
        case .hard: return 0.05
        }
    }

    private func offsetTolerance() -> CGFloat {
        switch difficulty {
        case .easy: return 22
        case .normal: return 16
        case .hard: return 12
        }
    }

    private func isAligned() -> Bool {
        let deltaAngle = abs(normalizedDegrees(userRotation - targetRotation))
        let deltaScale = abs(userScale - targetScale)
        let deltaOffset = hypot(userOffset.width, userOffset.height)
        return deltaAngle <= angleTolerance()
            && deltaScale <= scaleTolerance()
            && deltaOffset <= offsetTolerance()
    }

    private func normalizedDegrees(_ value: Double) -> Double {
        var v = value.truncatingRemainder(dividingBy: 360)
        if v > 180 { v -= 360 }
        if v < -180 { v += 360 }
        return abs(v)
    }

    private func starRating(won: Bool) -> Int {
        guard won else { return 0 }
        var score = 1
        if lockAttempts <= 1 { score += 1 }
        let ratio = secondsRemaining / max(1, sessionBudget)
        if ratio > 0.25 { score += 1 }
        return min(3, score)
    }
}
