//
//  ColorSplashView.swift
//  136KexmexcregrexPrellil
//

import SwiftUI

struct ColorSplashView: View {
    let difficulty: Difficulty
    let level: Int
    let onFinish: (Bool, Int, Double, Double) -> Void

    @StateObject private var model: ColorSplashViewModel
    @State private var flashScale: CGFloat = 1

    init(difficulty: Difficulty, level: Int, onFinish: @escaping (Bool, Int, Double, Double) -> Void) {
        self.difficulty = difficulty
        self.level = level
        self.onFinish = onFinish
        _model = StateObject(wrappedValue: ColorSplashViewModel(difficulty: difficulty, level: level))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Color Splash")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)

                Text(instructionLine)
                    .font(.body)
                    .foregroundStyle(Color.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                if model.phase != .ready {
                    progressHeader
                }

                if model.phase == .ready {
                    readyBoardPreview
                } else {
                    GeometryReader { geo in
                        VStack(spacing: 18) {
                            HStack(spacing: 10) {
                                ForEach(Array(model.targets.enumerated()), id: \.1.id) { index, target in
                                    targetCell(target: target, index: index, width: geo.size.width)
                                        .scaleEffect(model.lastMatchFlashIndex == index ? flashScale : 1)
                                }
                            }

                            HStack(spacing: 10) {
                                ForEach(model.swatches) { swatch in
                                    swatchCell(swatch: swatch, width: geo.size.width)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    }
                    .frame(minHeight: 300)
                }

                if case .finished = model.phase {
                    CasualPrimaryButton(title: "View Results") {
                        let summary = model.summary()
                        onFinish(summary.0, summary.1, summary.2, summary.3)
                    }
                } else if model.phase == .ready {
                    CasualSecondaryButton(title: "Start Round") {
                        model.startSession()
                    }
                } else {
                    Text(statusLine)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Color.appTextSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .appScreenBackground()
        .onDisappear {
            model.cancelTimers()
        }
        .onChange(of: model.phase) { newValue in
            if case .finished = newValue {
                model.cancelTimers()
            }
        }
        .onChange(of: model.lastMatchFlashIndex) { newValue in
            guard newValue != nil else { return }
            flashScale = 1.18
            withAnimation(.spring(response: 0.38, dampingFraction: 0.65)) {
                flashScale = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                model.clearMatchFlash()
            }
        }
    }

    private var paletteColumnCount: Int {
        switch difficulty {
        case .easy: return 3
        case .normal: return 4
        case .hard: return 5
        }
    }

    private var readyBoardPreview: some View {
        let n = paletteColumnCount
        return VStack(alignment: .leading, spacing: 12) {
            Text("Board preview")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.appTextSecondary)
            VStack(spacing: 18) {
                HStack(spacing: 10) {
                    ForEach(0 ..< n, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.appAccent.opacity(0.55), style: StrokeStyle(lineWidth: 2, dash: [7, 5]))
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color.appSurface.opacity(0.35))
                            )
                            .frame(height: 120)
                            .frame(maxWidth: .infinity)
                    }
                }
                HStack(spacing: 10) {
                    ForEach(0 ..< n, id: \.self) { idx in
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.appPrimary.opacity(0.55),
                                        Color.appAccent.opacity(0.45),
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: 92)
                            .frame(maxWidth: .infinity)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(Color.appTextPrimary.opacity(0.2), lineWidth: 1)
                            )
                            .opacity(0.75 + Double(idx) * 0.04)
                    }
                }
            }
            .padding(14)
            .appInsetPanelStyle(cornerRadius: 20)
        }
    }

    private var instructionLine: String {
        switch difficulty {
        case .easy:
            return "Drag swatches onto matching frames. Clear every wave before time runs out."
        case .normal:
            return "Frames shift between tiles, rings, and tilted tiles—infer the match fast."
        case .hard:
            return "A trap frame rejects every color. Avoid it, chain matches for bonus seconds."
        }
    }

    private var statusLine: String {
        if model.comboStreak >= 2 {
            return "Combo ×\(model.comboStreak). Three in a row grants bonus time."
        }
        return "Match hue to frame. Rings and diamonds read the same as tiles."
    }

    private var progressHeader: some View {
        let gaugeTotal = max(
            1,
            model.initialSessionTime + model.bonusSecondsEarned
        )
        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Time", systemImage: "timer")
                    .foregroundStyle(Color.appTextSecondary)
                Spacer()
                Text(String(format: "%.1fs", model.secondsRemaining))
                    .font(.headline.monospacedDigit())
                    .foregroundStyle(Color.appTextPrimary)
            }
            ProgressView(value: max(0, model.secondsRemaining), total: gaugeTotal)
                .tint(Color.appAccent)

            HStack {
                Label("Lives", systemImage: "heart.fill")
                    .foregroundStyle(Color.appTextSecondary)
                Spacer()
                Text("\(model.lives)")
                    .foregroundStyle(Color.appTextPrimary)
            }

            HStack(spacing: 12) {
                Text("Waves \(model.roundsCompleted)/\(model.totalRounds)")
                    .foregroundStyle(Color.appTextSecondary)
                if model.comboStreak > 0 {
                    Text("Combo \(model.comboStreak)")
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(Color.appPrimary)
                }
                if model.bonusSecondsEarned > 0.1 {
                    Text("+\(String(format: "%.1fs", model.bonusSecondsEarned)) bonus")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(Color.appAccent)
                }
                Spacer()
            }
        }
        .padding(14)
        .appInsetPanelStyle()
    }

    private func targetCell(target: ColorSplashViewModel.TargetSlot, index: Int, width: CGFloat) -> some View {
        let columnWidth = (width - CGFloat(max(model.targets.count - 1, 0)) * 10) / CGFloat(max(model.targets.count, 1))
        let fill = target.filled ? Color.appPrimary.opacity(0.38) : Color.appSurface.opacity(0.5)
        let strokeOuter = target.isDecoy ? Color.appPrimary.opacity(0.9) : Color.appAccent.opacity(0.65)

        return ZStack {
            SlotChrome(style: target.style, columnWidth: columnWidth)
                .fill(fill)
                .overlay(
                    SlotChrome(style: target.style, columnWidth: columnWidth)
                        .stroke(strokeOuter, lineWidth: target.isDecoy ? 4 : 3)
                )

            if target.isDecoy {
                Text("Trap")
                    .font(.caption2.weight(.heavy))
                    .foregroundStyle(Color.appPrimary)
            } else if !target.filled {
                Circle()
                    .stroke(Color.appTextSecondary.opacity(0.72), style: StrokeStyle(lineWidth: 2, dash: [6, 6]))
                    .padding(10)
            }
        }
        .frame(width: columnWidth, height: 126)
        .contentShape(Rectangle())
    }

    private struct SlotChrome: Shape {
        let style: ColorSplashViewModel.SlotStyle
        let columnWidth: CGFloat

        func path(in rect: CGRect) -> Path {
            switch style {
            case .tile:
                return RoundedRectangle(cornerRadius: 16, style: .continuous).path(in: rect)
            case .ring:
                return Circle().path(in: rect)
            case .diamond:
                var t = CGAffineTransform(translationX: rect.midX, y: rect.midY)
                t = t.rotated(by: .pi * 0.22)
                t = t.translatedBy(x: -rect.midX, y: -rect.midY)
                let r = CGRect(x: rect.minX + 4, y: rect.minY + 4, width: rect.width - 8, height: rect.height - 8)
                return RoundedRectangle(cornerRadius: 12, style: .continuous).path(in: r).applying(t)
            }
        }
    }

    private func swatchCell(swatch: ColorSplashViewModel.Swatch, width: CGFloat) -> some View {
        let columnWidth = (width - CGFloat(max(model.swatches.count - 1, 0)) * 10) / CGFloat(max(model.swatches.count, 1))
        return RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [swatch.color, swatch.color.opacity(0.82)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: columnWidth, height: 92)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.appTextPrimary.opacity(0.28), lineWidth: 1)
            )
            .shadow(color: Color.appPrimary.opacity(0.32), radius: 10, y: 5)
            .gesture(
                DragGesture(minimumDistance: 2)
                    .onEnded { value in
                        guard model.phase == .playing else { return }
                        guard let swatchIndex = model.swatches.firstIndex(where: { $0.id == swatch.id }) else { return }
                        let slotWidth = (width - CGFloat(max(model.targets.count - 1, 0)) * 10) / CGFloat(max(model.targets.count, 1))
                        let stride = slotWidth + 10
                        let globalX = CGFloat(swatchIndex) * stride + value.startLocation.x + value.predictedEndTranslation.width
                        let index = Int((globalX / stride).rounded(.towardZero))
                        let clamped = min(max(index, 0), model.targets.count - 1)
                        model.attemptDrop(swatchID: swatch.id, targetIndex: clamped)
                    }
            )
            .accessibilityLabel("Draggable swatch")
    }
}
