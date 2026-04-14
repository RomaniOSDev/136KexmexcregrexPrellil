//
//  OnboardingView.swift
//  136KexmexcregrexPrellil
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var store: AppStorage
    @State private var page = 0

    var body: some View {
        ZStack {
            AppVisual.screenGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $page) {
                    OnboardingPageIntro().tag(0)
                    OnboardingPagePlay().tag(1)
                    OnboardingPageStars().tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                pageIndicator
                    .padding(.top, 8)
                    .padding(.bottom, 4)

                VStack(spacing: 14) {
                    if page < 2 {
                        CasualPrimaryButton(title: "Continue") {
                            withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                                page += 1
                            }
                        }
                    } else {
                        CasualPrimaryButton(title: "Enter") {
                            store.markOnboardingFinished()
                        }
                    }

                    Button("Skip") {
                        store.markOnboardingFinished()
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appTextSecondary)
                    .frame(minHeight: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 28)
                .background(
                    LinearGradient(
                        colors: [
                            Color.appBackground.opacity(0.001),
                            Color.appBackground.opacity(0.55),
                            Color.appPrimary.opacity(0.06),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea(edges: .bottom)
                )
            }
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 10) {
            ForEach(0 ..< 3, id: \.self) { idx in
                if idx == page {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color.appPrimary, Color.appAccent],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 32, height: 9)
                } else {
                    Capsule()
                        .fill(Color.appTextSecondary.opacity(0.22))
                        .frame(width: 9, height: 9)
                }
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: page)
    }
}

// MARK: - Pages

private struct OnboardingPageIntro: View {
    @State private var pulse = false

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                pageHeader(
                    step: "01 · Flow",
                    title: "Bright, quick sessions",
                    subtitle: "Tiny bursts of motion, color, and rhythm keep every round lively."
                )

                ZStack {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.appSurface.opacity(0.95),
                                    Color.appPrimary.opacity(0.08),
                                    Color.appAccent.opacity(0.06),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Canvas { context, size in
                        let center = CGPoint(x: size.width / 2, y: size.height / 2)
                        let radius = min(size.width, size.height) * 0.28 * (pulse ? 1.08 : 0.92)
                        var path = Path()
                        path.addArc(center: center, radius: radius, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: true)
                        context.stroke(path, with: .color(Color.appAccent), lineWidth: 6)
                        var inner = Path()
                        inner.addArc(center: center, radius: radius * 0.55, startAngle: .degrees(20), endAngle: .degrees(320), clockwise: false)
                        context.stroke(inner, with: .color(Color.appPrimary), lineWidth: 5)
                    }
                    .padding(28)
                }
                .frame(height: 236)
                .padding(18)
                .appElevatedCardStyle(cornerRadius: 28)
                .padding(.horizontal, 16)
            }
            .padding(.top, 36)
            .padding(.bottom, 32)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}

private struct OnboardingPagePlay: View {
    @State private var tilt = false

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                pageHeader(
                    step: "02 · Touch",
                    title: "Touch-first play",
                    subtitle: "Drag, rotate, scale, and tap with controls tuned for one-thumb reach."
                )

                ZStack {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.appSurface.opacity(0.95),
                                    Color.appAccent.opacity(0.05),
                                    Color.appPrimary.opacity(0.07),
                                ],
                                startPoint: .bottomLeading,
                                endPoint: .topTrailing
                            )
                        )
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(AppVisual.primaryButtonGradient)
                        .frame(width: 120, height: 120)
                        .shadow(color: Color.appPrimary.opacity(0.45), radius: 16, x: 0, y: 8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.appTextPrimary.opacity(0.15), lineWidth: 1)
                        )
                        .rotationEffect(.degrees(tilt ? 12 : -10))
                        .offset(x: tilt ? 10 : -12, y: tilt ? -6 : 8)
                        .animation(.spring(response: 0.55, dampingFraction: 0.72).repeatForever(autoreverses: true), value: tilt)
                }
                .frame(height: 236)
                .padding(18)
                .appElevatedCardStyle(cornerRadius: 28)
                .padding(.horizontal, 16)
            }
            .padding(.top, 36)
            .padding(.bottom, 32)
        }
        .onAppear { tilt = true }
    }
}

private struct OnboardingPageStars: View {
    @State private var glow = false

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                pageHeader(
                    step: "03 · Mastery",
                    title: "Stars mark mastery",
                    subtitle: "Replay levels to chase cleaner runs, faster clears, and brighter star lines."
                )

                ZStack {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.appSurface.opacity(0.95),
                                    Color.appAccent.opacity(0.07),
                                    Color.appPrimary.opacity(0.05),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    HStack(spacing: 20) {
                        ForEach(0 ..< 3, id: \.self) { index in
                            StarShape()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.appAccent, Color.appPrimary.opacity(0.88)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 46, height: 46)
                                .shadow(color: Color.appAccent.opacity(glow ? 0.75 : 0.3), radius: glow ? 18 : 8, y: 6)
                                .scaleEffect(glow ? 1.06 : 0.9)
                                .animation(
                                    .spring(response: 0.45, dampingFraction: 0.68)
                                        .delay(Double(index) * 0.12),
                                    value: glow
                                )
                        }
                    }
                }
                .frame(height: 236)
                .padding(18)
                .appElevatedCardStyle(cornerRadius: 28)
                .padding(.horizontal, 16)
            }
            .padding(.top, 36)
            .padding(.bottom, 32)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
                glow = true
            }
        }
    }
}

// MARK: - Shared header

private func pageHeader(step: String, title: String, subtitle: String) -> some View {
    VStack(spacing: 12) {
        Text(step)
            .font(.caption.weight(.heavy))
            .foregroundStyle(Color.appAccent)
            .textCase(.uppercase)
            .tracking(1.1)
        Text(title)
            .font(.system(size: 28, weight: .bold, design: .rounded))
            .foregroundStyle(Color.appTextPrimary)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
        Text(subtitle)
            .font(.body)
            .foregroundStyle(Color.appTextSecondary)
            .multilineTextAlignment(.center)
            .lineSpacing(4)
            .fixedSize(horizontal: false, vertical: true)
    }
    .padding(.horizontal, 20)
}

private struct StarShape: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        var path = Path()
        let points = 5
        let adjustment = CGFloat.pi / 2
        for index in 0 ..< points * 2 {
            let angle = CGFloat(index) * .pi / CGFloat(points) - adjustment
            let r = index.isMultiple(of: 2) ? radius : radius * 0.45
            let point = CGPoint(x: center.x + cos(angle) * r, y: center.y + sin(angle) * r)
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}
