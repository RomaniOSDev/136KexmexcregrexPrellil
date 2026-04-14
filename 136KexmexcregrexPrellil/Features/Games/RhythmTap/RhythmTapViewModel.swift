//
//  RhythmTapViewModel.swift
//  136KexmexcregrexPrellil
//

import Combine
import Foundation

@MainActor
final class RhythmTapViewModel: ObservableObject {
    enum Phase: Equatable {
        case ready
        case playing
        case finished(win: Bool)
    }

    enum TapQuality: Equatable {
        case none
        case ok
        case perfect
    }

    let difficulty: Difficulty
    let level: Int

    @Published private(set) var phase: Phase = .ready
    @Published private(set) var hits: Int = 0
    @Published private(set) var misses: Int = 0
    @Published private(set) var beatIndex: Int = 0
    @Published private(set) var secondsToNextBeat: Double = 0
    @Published private(set) var beatCount: Int = 0
    @Published private(set) var perfectHits: Int = 0
    @Published private(set) var comboStreak: Int = 0
    @Published private(set) var bestCombo: Int = 0
    @Published private(set) var lastTapQuality: TapQuality = .none

    private var beatTimes: [TimeInterval] = []
    private var consumed: Set<Int> = []
    private var perfectBeatIndices: Set<Int> = []
    private var sessionStart: Date?
    private var timerCancellable: AnyCancellable?
    private let startDate = Date()

    init(difficulty: Difficulty, level: Int) {
        self.difficulty = difficulty
        self.level = level
    }

    func startSession() {
        hits = 0
        misses = 0
        perfectHits = 0
        comboStreak = 0
        bestCombo = 0
        lastTapQuality = .none
        consumed.removeAll()
        perfectBeatIndices.removeAll()
        beatCount = 6 + min(4, level)
        let bpm = baseBPM()
        let interval = 60.0 / bpm
        let leadIn = 1.15
        beatTimes = (1 ... beatCount).map { index in
            leadIn + Double(index) * interval
        }
        sessionStart = Date()
        phase = .playing
        beatIndex = 0
        timerCancellable?.cancel()
        timerCancellable = Timer.publish(every: 0.05, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    func cancelTimers() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    func handleTap() {
        guard case .playing = phase else { return }
        guard let start = sessionStart else { return }
        let now = Date().timeIntervalSince(start)

        if let target = nextEligibleBeatIndex(currentTime: now) {
            let delta = abs(now - beatTimes[target])
            let inner = tapWindow() * innerPerfectRatio()
            if delta <= inner {
                perfectHits += 1
                comboStreak += 1
                bestCombo = max(bestCombo, comboStreak)
                lastTapQuality = .perfect
                perfectBeatIndices.insert(target)
            } else {
                comboStreak = 0
                lastTapQuality = .ok
            }
            consumed.insert(target)
            hits += 1
            return
        }

        comboStreak = 0
        lastTapQuality = .none
        misses += 1
    }

    func isBeatResolved(_ index: Int) -> Bool {
        consumed.contains(index)
    }

    func isPerfectBeat(_ index: Int) -> Bool {
        perfectBeatIndices.contains(index)
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
        let total = max(1, hits + misses)
        let accuracy = Double(hits) / Double(total) * 100
        return (won, stars, duration, accuracy)
    }

    private func tick() {
        guard case .playing = phase else { return }
        guard let start = sessionStart else { return }
        let now = Date().timeIntervalSince(start)

        if let nextIndex = (0 ..< beatCount).first(where: { !consumed.contains($0) }) {
            secondsToNextBeat = max(0, beatTimes[nextIndex] - now)
            beatIndex = nextIndex
        } else {
            secondsToNextBeat = 0
        }

        let lastTime = beatTimes.last ?? 0
        if now > lastTime + tapWindow() + 0.35 {
            finalizeIfNeeded(currentTime: now)
        }
    }

    private func finalizeIfNeeded(currentTime now: TimeInterval) {
        guard case .playing = phase else { return }
        let lastTime = beatTimes.last ?? 0
        let allBeatsHandled = consumed.count == beatCount
        guard allBeatsHandled || now > lastTime + tapWindow() + 0.35 else { return }

        let requiredHits = max(1, Int(ceil(Double(beatCount) * accuracyRequirement())))
        let win = hits >= requiredHits
        finish(win: win)
    }

    private func finish(win: Bool) {
        timerCancellable?.cancel()
        timerCancellable = nil
        phase = .finished(win: win)
    }

    private func nextEligibleBeatIndex(currentTime: TimeInterval) -> Int? {
        (0 ..< beatCount).first { index in
            !consumed.contains(index) && abs(currentTime - beatTimes[index]) <= tapWindow()
        }
    }

    private func innerPerfectRatio() -> Double {
        switch difficulty {
        case .easy: return 0.5
        case .normal: return 0.48
        case .hard: return 0.42
        }
    }

    private func tapWindow() -> TimeInterval {
        switch difficulty {
        case .easy: return 0.22
        case .normal: return 0.18
        case .hard: return 0.14
        }
    }

    private func accuracyRequirement() -> Double {
        switch difficulty {
        case .easy: return 0.62
        case .normal: return 0.72
        case .hard: return 0.82
        }
    }

    private func baseBPM() -> Double {
        let base: Double
        switch difficulty {
        case .easy: base = 58
        case .normal: base = 74
        case .hard: base = 90
        }
        return base + Double(level - 1) * 3
    }

    private func starRating(won: Bool) -> Int {
        guard won else { return 0 }
        let ratio = Double(hits) / Double(max(1, beatCount))
        let perfectRatio = Double(perfectHits) / Double(max(1, hits))
        if ratio >= 0.96, perfectRatio >= 0.55 { return 3 }
        if ratio >= 0.86 { return 2 }
        return 1
    }
}
