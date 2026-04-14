//
//  ShapeShiftView.swift
//  136KexmexcregrexPrellil
//

import SwiftUI

struct ShapeShiftView: View {
    let difficulty: Difficulty
    let level: Int
    let onFinish: (Bool, Int, Double, Double) -> Void

    @StateObject private var model: ShapeShiftViewModel
    @GestureState private var pinch: CGFloat = 1
    @GestureState private var twist: Angle = .degrees(0)
    @GestureState private var drag: CGSize = .zero
    @Namespace private var shapeSpace

    init(difficulty: Difficulty, level: Int, onFinish: @escaping (Bool, Int, Double, Double) -> Void) {
        self.difficulty = difficulty
        self.level = level
        self.onFinish = onFinish
        _model = StateObject(wrappedValue: ShapeShiftViewModel(difficulty: difficulty, level: level))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Shape Shift")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)

                Text(kindBlurb)
                    .font(.body)
                    .foregroundStyle(Color.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                hud

                ZStack {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.appSurface.opacity(0.75),
                                    Color.appPrimary.opacity(0.06),
                                    Color.appAccent.opacity(0.05),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 340)
                        .shadow(color: Color.appPrimary.opacity(0.14), radius: 16, x: 0, y: 8)

                    alignmentRing

                    // Draggable piece sits under the target outline so the rim stays visible.
                    interactivePiece
                        .gesture(combinedGesture)

                    silhouetteStack
                }
                .frame(maxWidth: .infinity)
                .frame(height: 340, alignment: .center)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .padding(.vertical, 6)

                CasualPrimaryButton(title: "Lock placement") {
                    model.lockPlacement()
                }
                .disabled(model.phase != .playing)

                if case .finished = model.phase {
                    CasualSecondaryButton(title: "View Results") {
                        let summary = model.summary()
                        onFinish(summary.0, summary.1, summary.2, summary.3)
                    }
                } else if model.phase == .ready {
                    CasualSecondaryButton(title: "Start shaping") {
                        model.startSession()
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .appScreenBackground()
        .onChange(of: model.userRotation) { _ in model.refreshFitGauge() }
        .onChange(of: model.userScale) { _ in model.refreshFitGauge() }
        .onChange(of: model.userOffset.width) { _ in model.refreshFitGauge() }
        .onChange(of: model.userOffset.height) { _ in model.refreshFitGauge() }
        .onDisappear { model.cancelTimers() }
        .onChange(of: model.phase) { newValue in
            if case .finished = newValue {
                model.cancelTimers()
            }
        }
    }

    private var kindBlurb: String {
        let base = "Pinch, twist, and drag until the solid piece hugs the outline—use the ring as a fit hint."
        if case .ready = model.phase {
            return base + " Each run rolls a different outline family."
        }
        switch model.outlineKind {
        case .blob:
            return base + " Organic curves—follow the scalloped rim."
        case .kite:
            return base + " Kite frame—nail the diagonal corners."
        case .wedge:
            return base + " Wedge arc—mind the point and belly."
        }
    }

    private var alignmentRing: some View {
        Circle()
            .trim(from: 0, to: CGFloat(model.alignmentScore))
            .stroke(
                Color.appAccent,
                style: StrokeStyle(lineWidth: 6, lineCap: .round)
            )
            .rotationEffect(.degrees(-90))
            .frame(width: 268, height: 268)
            .opacity(model.phase == .playing ? 1 : 0.35)
            .animation(.easeOut(duration: 0.18), value: model.alignmentScore)
    }

    private var hud: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Time", systemImage: "timer")
                    .foregroundStyle(Color.appTextSecondary)
                Spacer()
                Text(String(format: "%.1fs", model.secondsRemaining))
                    .font(.headline.monospacedDigit())
                    .foregroundStyle(Color.appTextPrimary)
            }
            ProgressView(value: max(0, model.secondsRemaining), total: max(1, model.sessionBudget))
                .tint(Color.appAccent)
            HStack {
                Text("Lock tries: \(model.lockAttempts)")
                    .foregroundStyle(Color.appTextSecondary)
                Spacer()
                Text("Fit \(Int(model.alignmentScore * 100))%")
                    .font(.subheadline.weight(.bold).monospacedDigit())
                    .foregroundStyle(Color.appPrimary)
            }
        }
        .padding(14)
        .appInsetPanelStyle()
    }

    private var silhouetteStack: some View {
        ZStack {
            OutlineShape(kind: model.outlineKind)
                .stroke(Color.appTextPrimary.opacity(0.72), lineWidth: 5)
                .frame(width: 200, height: 200)
                .scaleEffect(model.targetScale)
                .rotationEffect(.degrees(model.targetRotation))
                .blur(radius: difficulty == .hard ? 1.2 : 0)
                .overlay(
                    Group {
                        if difficulty == .hard {
                            Rectangle()
                                .fill(Color.appSurface.opacity(0.55))
                                .frame(width: 120, height: 90)
                                .offset(x: 40, y: -30)
                                .rotationEffect(.degrees(8))
                        }
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            Circle()
                .fill(Color.appAccent.opacity(0.38))
                .frame(width: 18, height: 18)
                .offset(x: offsetForKind(model.outlineKind).x, y: offsetForKind(model.outlineKind).y)
                .matchedGeometryEffect(id: "hintPulse", in: shapeSpace)
        }
    }

    private func offsetForKind(_ kind: ShapeShiftViewModel.OutlineKind) -> CGPoint {
        switch kind {
        case .blob: return CGPoint(x: 86, y: -70)
        case .kite: return CGPoint(x: 0, y: -92)
        case .wedge: return CGPoint(x: 72, y: 48)
        }
    }

    private var interactivePiece: some View {
        interactivePieceCore
            .scaleEffect(model.userScale * pinch)
            .rotationEffect(.degrees(model.userRotation) + twist)
            .offset(x: model.userOffset.width + drag.width, y: model.userOffset.height + drag.height)
            .animation(.spring(response: 0.45, dampingFraction: 0.78), value: model.userScale)
            .animation(.spring(response: 0.45, dampingFraction: 0.78), value: model.userRotation)
    }

    private var interactivePieceCore: some View {
        ZStack {
            OutlineShape(kind: model.outlineKind)
                .fill(Color.appPrimary.opacity(0.62))
                .frame(width: 200, height: 200)
            Circle()
                .fill(Color.appAccent.opacity(0.55))
                .frame(width: 18, height: 18)
                .offset(x: offsetForKind(model.outlineKind).x, y: offsetForKind(model.outlineKind).y)
                .matchedGeometryEffect(id: "hintPulse", in: shapeSpace)
        }
    }

    private var pinchGesture: some Gesture {
        MagnificationGesture()
            .updating($pinch) { value, state, _ in
                state = value
            }
            .onEnded { value in
                model.userScale = max(0.6, min(1.6, model.userScale * value))
            }
    }

    private var rotationGesture: some Gesture {
        RotationGesture()
            .updating($twist) { value, state, _ in
                state = value
            }
            .onEnded { value in
                model.userRotation += value.degrees
            }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .updating($drag) { value, state, _ in
                state = value.translation
            }
            .onEnded { value in
                model.userOffset.width += value.translation.width
                model.userOffset.height += value.translation.height
            }
    }

    private var combinedGesture: some Gesture {
        let pinchAndRotate = SimultaneousGesture(pinchGesture, rotationGesture)
        return SimultaneousGesture(pinchAndRotate, dragGesture)
    }
}

private struct OutlineShape: Shape {
    let kind: ShapeShiftViewModel.OutlineKind

    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        switch kind {
        case .blob:
            var path = Path()
            path.move(to: CGPoint(x: w * 0.15, y: h * 0.35))
            path.addQuadCurve(to: CGPoint(x: w * 0.5, y: h * 0.08), control: CGPoint(x: w * 0.25, y: h * 0.05))
            path.addQuadCurve(to: CGPoint(x: w * 0.88, y: h * 0.32), control: CGPoint(x: w * 0.82, y: h * 0.12))
            path.addQuadCurve(to: CGPoint(x: w * 0.78, y: h * 0.78), control: CGPoint(x: w * 0.95, y: h * 0.58))
            path.addQuadCurve(to: CGPoint(x: w * 0.22, y: h * 0.82), control: CGPoint(x: w * 0.55, y: h * 0.95))
            path.addQuadCurve(to: CGPoint(x: w * 0.15, y: h * 0.35), control: CGPoint(x: w * 0.05, y: h * 0.55))
            path.closeSubpath()
            return path
        case .kite:
            var path = Path()
            path.move(to: CGPoint(x: w * 0.5, y: h * 0.08))
            path.addLine(to: CGPoint(x: w * 0.88, y: h * 0.42))
            path.addLine(to: CGPoint(x: w * 0.5, y: h * 0.92))
            path.addLine(to: CGPoint(x: w * 0.12, y: h * 0.42))
            path.closeSubpath()
            return path
        case .wedge:
            var path = Path()
            path.move(to: CGPoint(x: w * 0.5, y: h * 0.1))
            path.addQuadCurve(to: CGPoint(x: w * 0.9, y: h * 0.65), control: CGPoint(x: w * 0.88, y: h * 0.28))
            path.addQuadCurve(to: CGPoint(x: w * 0.5, y: h * 0.9), control: CGPoint(x: w * 0.75, y: h * 0.92))
            path.addQuadCurve(to: CGPoint(x: w * 0.1, y: h * 0.65), control: CGPoint(x: w * 0.12, y: h * 0.28))
            path.closeSubpath()
            return path
        }
    }
}
