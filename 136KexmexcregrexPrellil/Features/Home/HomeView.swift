//
//  HomeView.swift
//  136KexmexcregrexPrellil
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: AppStorage
    @State private var path = NavigationPath()
    @State private var heroAppear = false

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    heroSection
                        .padding(.bottom, 28)

                    meritCard
                        .padding(.bottom, 22)

                    quickStatsSection
                        .padding(.bottom, 26)

                    activitiesSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
                .padding(.bottom, 60)
            }
            .appScreenBackground()
            //.mainTabBarBottomClearance()
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: ActivityKind.self) { activity in
                LevelHubView(activity: activity, path: $path)
            }
            .navigationDestination(for: LevelRoute.self) { route in
                switch route {
                case let .play(activity, diff, level):
                    GameHostView(path: $path, activity: activity, difficulty: diff, level: level)
                case let .result(activity, diff, level, outcome):
                    ActivityResultView(path: $path, activity: activity, difficulty: diff, level: level, outcome: outcome)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.55)) {
                heroAppear = true
            }
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        let mp = store.meritProgressSnapshot()
        return ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.appPrimary.opacity(0.42),
                            Color.appAccent.opacity(0.28),
                            Color.appSurface.opacity(0.55),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.appAccent.opacity(0.22), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 12) {
                Text(Date.now, format: .dateTime.weekday(.wide).month(.abbreviated).day())
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary.opacity(0.85))

                Text("Your studio")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.appTextPrimary)
                    .opacity(heroAppear ? 1 : 0)
                    .offset(y: heroAppear ? 0 : 8)

                Text("Warm up on Easy, then chase three-star clears across every flow.")
                    .font(.body)
                    .foregroundStyle(Color.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(3)

                HStack(spacing: 8) {
                    Image(systemName: "seal.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.appPrimary)
                    Text(mp.rank.displayTitle)
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(Color.appTextPrimary)
                    Text("·")
                        .foregroundStyle(Color.appTextSecondary.opacity(0.88))
                    Text("\(mp.totalStars) stars")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.appTextSecondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule(style: .continuous)
                        .fill(Color.appBackground.opacity(0.45))
                )
            }
            .padding(22)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .shadow(color: Color.appPrimary.opacity(0.12), radius: 20, y: 10)
    }

    // MARK: - Merit

    private var meritCard: some View {
        let mp = store.meritProgressSnapshot()
        return VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Merit path")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.appAccent)
                        .textCase(.uppercase)
                        .tracking(0.6)
                    Text(mp.rank.tagline)
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 8)
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Color.appPrimary.opacity(0.85))
            }

            if let need = mp.starsToNextRank, let next = mp.rank.next() {
                Text("Next: \(next.displayTitle) — \(need) stars")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color.appTextSecondary)
            } else {
                Text("Highest merit band")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color.appAccent)
            }

            ProgressView(value: mp.fractionToNext, total: 1)
                .tint(Color.appAccent)
                .scaleEffect(x: 1, y: 1.35, anchor: .center)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appElevatedCardStyle()
    }

    // MARK: - Quick stats

    private var quickStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("At a glance")
                .font(.headline.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)

            HStack(spacing: 10) {
                statTile(
                    icon: "star.fill",
                    title: "Stars",
                    value: "\(store.totalStarsSum())",
                    tint: Color.appAccent
                )
                statTile(
                    icon: "flag.checkered",
                    title: "Wins",
                    value: "\(store.totalWins)",
                    tint: Color.appPrimary
                )
                statTile(
                    icon: "play.circle.fill",
                    title: "Sessions",
                    value: "\(store.sessionsFinished)",
                    tint: Color.appAccent.opacity(0.9)
                )
            }
        }
    }

    private func statTile(icon: String, title: String, value: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(tint)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(tint.opacity(0.15))
                )
            Text(title.uppercased())
                .font(.caption2.weight(.bold))
                .foregroundStyle(Color.appTextSecondary)
                .tracking(0.3)
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .appElevatedCardStyle(cornerRadius: 18)
    }

    // MARK: - Activities

    private var activitiesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Activities")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
                Text("\(store.unlockedAchievementCount()) milestones")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.appTextSecondary)
            }

            VStack(spacing: 12) {
                ForEach(ActivityKind.allCases) { activity in
                    Button {
                        path.append(activity)
                    } label: {
                        activityRow(activity)
                    }
                    .buttonStyle(ActivityCardButtonStyle())
                }
            }
        }
    }

    private func activityRow(_ activity: ActivityKind) -> some View {
        let gradient = activityGradient(for: activity)
        return HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.appTextPrimary.opacity(0.12), lineWidth: 1)
                    )
                ActivityGlyph(activity: activity)
                    .frame(width: 30, height: 30)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(activity.displayTitle)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary)
                Text(activity.shortBlurb)
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color.appAccent)
                .padding(10)
                .background(
                    Circle()
                        .fill(Color.appAccent.opacity(0.12))
                )
        }
        .padding(16)
        .appElevatedCardStyle()
    }

    private func activityGradient(for activity: ActivityKind) -> [Color] {
        switch activity {
        case .colorSplash:
            return [Color.appPrimary.opacity(0.55), Color.appAccent.opacity(0.35)]
        case .shapeShift:
            return [Color.appAccent.opacity(0.45), Color.appPrimary.opacity(0.35)]
        case .rhythmTap:
            return [Color.appPrimary.opacity(0.4), Color.appAccent.opacity(0.45)]
        }
    }
}

// MARK: - Button style

private struct ActivityCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.92 : 1)
            .animation(.easeOut(duration: 0.18), value: configuration.isPressed)
    }
}

// MARK: - Glyphs

struct ActivityGlyph: View {
    let activity: ActivityKind

    var body: some View {
        Canvas { context, size in
            let rect = CGRect(origin: .zero, size: size)
            switch activity {
            case .colorSplash:
                let colors: [Color] = [Color.appPrimary, Color.appAccent, Color.appSurface]
                let step = rect.width / CGFloat(colors.count)
                for (idx, color) in colors.enumerated() {
                    let cell = Path(roundedRect: CGRect(x: CGFloat(idx) * step, y: 0, width: step, height: rect.height), cornerRadius: 6)
                    context.fill(cell, with: .color(color))
                }
            case .shapeShift:
                var diamond = Path()
                diamond.move(to: CGPoint(x: rect.midX, y: rect.minY + 4))
                diamond.addLine(to: CGPoint(x: rect.maxX - 4, y: rect.midY))
                diamond.addLine(to: CGPoint(x: rect.midX, y: rect.maxY - 4))
                diamond.addLine(to: CGPoint(x: rect.minX + 4, y: rect.midY))
                diamond.closeSubpath()
                context.fill(diamond, with: .color(Color.appSurface.opacity(0.95)))
            case .rhythmTap:
                let spacing = rect.width / 5
                for index in 0 ..< 4 {
                    let bar = Path(roundedRect: CGRect(x: 6 + CGFloat(index) * spacing, y: rect.midY - CGFloat(10 + index * 4), width: 8, height: CGFloat(20 + index * 6)), cornerRadius: 3)
                    context.fill(bar, with: .color(Color.appSurface.opacity(0.95)))
                }
            }
        }
    }
}
