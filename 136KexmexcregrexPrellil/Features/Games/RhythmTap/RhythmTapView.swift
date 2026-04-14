//
//  RhythmTapView.swift
//  136KexmexcregrexPrellil
//

import SwiftUI

struct RhythmTapView: View {
    let difficulty: Difficulty
    let level: Int
    let onFinish: (Bool, Int, Double, Double) -> Void

    @StateObject private var model: RhythmTapViewModel
    @State private var pulseScale: CGFloat = 1

    init(difficulty: Difficulty, level: Int, onFinish: @escaping (Bool, Int, Double, Double) -> Void) {
        self.difficulty = difficulty
        self.level = level
        self.onFinish = onFinish
        _model = StateObject(wrappedValue: RhythmTapViewModel(difficulty: difficulty, level: level))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Rhythm Tap")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)

                Text("Tap when the big disc pulses with the outer ring—tighter taps build perfect combos.")
                    .font(.body)
                    .foregroundStyle(Color.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                beatTimeline

                VStack(spacing: 18) {
                    ZStack {
                        Circle()
                            .stroke(Color.appSurface, lineWidth: 14)
                            .frame(width: 220, height: 220)
                        Circle()
                            .stroke(Color.appAccent.opacity(0.5), lineWidth: 10)
                            .frame(width: 220, height: 220)
                            .scaleEffect(pulseScale)

                        Circle()
                            .fill(Color.appPrimary.opacity(0.88))
                            .frame(width: 118, height: 118)
                            .shadow(color: Color.appPrimary.opacity(0.45), radius: 18, y: 6)

                        tapQualityLabel
                    }
                    .padding(.top, 8)

                    Text("Next beat in \(String(format: "%.2fs", model.secondsToNextBeat))")
                        .font(.headline.monospacedDigit())
                        .foregroundStyle(Color.appTextPrimary)

                    HStack {
                        statChip(title: "Hits", value: "\(model.hits)")
                        statChip(title: "Perfect", value: "\(model.perfectHits)")
                        statChip(title: "Combo", value: "\(model.bestCombo)")
                    }

                    if model.phase == .playing, model.comboStreak >= 2 {
                        Text("Live combo ×\(model.comboStreak)")
                            .font(.caption.weight(.heavy))
                            .foregroundStyle(Color.appAccent)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .padding(.horizontal, 4)
                .appElevatedCardStyle(cornerRadius: 22)

                Button(action: {
                    model.handleTap()
                }) {
                    Text("Tap")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Color.appTextPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(AppVisual.primaryButtonGradient)
                                .shadow(color: Color.appPrimary.opacity(0.42), radius: 12, x: 0, y: 6)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.appTextPrimary.opacity(0.12), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                .disabled(model.phase != .playing)

                if case .finished = model.phase {
                    CasualSecondaryButton(title: "View Results") {
                        let summary = model.summary()
                        onFinish(summary.0, summary.1, summary.2, summary.3)
                    }
                } else if model.phase == .ready {
                    CasualSecondaryButton(title: "Start cadence") {
                        model.startSession()
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .appScreenBackground()
        .onAppear {
            pulseScale = 1.06
        }
        .onChange(of: model.secondsToNextBeat) { value in
            let shrink = min(1.18, 1.03 + CGFloat(0.35 / max(0.2, value + 0.08)))
            withAnimation(.easeInOut(duration: 0.12)) {
                pulseScale = shrink
            }
        }
        .onDisappear { model.cancelTimers() }
        .onChange(of: model.phase) { newValue in
            if case .finished = newValue {
                model.cancelTimers()
            }
        }
    }

    private var beatTimeline: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Beat lane")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.appTextSecondary)
            if model.beatCount == 0 {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Start the cadence to wake the lane.")
                        .font(.footnote)
                        .foregroundStyle(Color.appTextSecondary)
                    HStack(spacing: 8) {
                        ForEach(0 ..< 8, id: \.self) { idx in
                            Circle()
                                .fill(Color.appAccent.opacity(0.15 + Double(idx % 3) * 0.06))
                                .frame(width: 28, height: 28)
                                .overlay(
                                    Circle()
                                        .stroke(Color.appAccent.opacity(0.35), lineWidth: 1)
                                )
                        }
                    }
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(0 ..< model.beatCount, id: \.self) { index in
                            beatOrb(index: index)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding(14)
        .appInsetPanelStyle()
    }

    private func beatOrb(index: Int) -> some View {
        let resolved = model.phase != .ready && model.isBeatResolved(index)
        let perfect = model.isPerfectBeat(index)
        let isNext = index == model.beatIndex && model.phase == .playing && !resolved
        return ZStack {
            Circle()
                .fill(resolved ? Color.appAccent.opacity(0.72) : Color.appSurface.opacity(0.42))
                .frame(width: 36, height: 36)
                .overlay(
                    Circle()
                        .stroke(isNext ? Color.appPrimary : Color.appAccent.opacity(0.38), lineWidth: isNext ? 3 : 1.2)
                )
            if resolved {
                Image(systemName: perfect ? "sparkles" : "checkmark")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
            }
        }
        .scaleEffect(isNext ? 1.14 : 1)
        .animation(.spring(response: 0.38, dampingFraction: 0.72), value: isNext)
    }

    @ViewBuilder
    private var tapQualityLabel: some View {
        switch model.lastTapQuality {
        case .perfect:
            Text("Perfect")
                .font(.caption.weight(.heavy))
                .foregroundStyle(Color.appAccent)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Capsule().fill(Color.appSurface.opacity(0.5)))
        case .ok:
            Text("Good")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(Color.appTextSecondary)
        case .none:
            EmptyView()
        }
    }

    private func statChip(title: String, value: String) -> some View {
        VStack(spacing: 6) {
            Text(title.uppercased())
                .font(.caption2.weight(.semibold))
                .foregroundStyle(Color.appTextSecondary)
            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AppVisual.surfaceSheen)
                .shadow(color: Color.appPrimary.opacity(0.08), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(AppVisual.cardBorderGradient.opacity(0.4), lineWidth: 1)
        )
    }
}
