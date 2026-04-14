//
//  ActivityResultView.swift
//  136KexmexcregrexPrellil
//

import SwiftUI

struct ActivityResultView: View {
    @EnvironmentObject private var store: AppStorage
    @Binding var path: NavigationPath
    let activity: ActivityKind
    let difficulty: Difficulty
    let level: Int
    let outcome: SessionOutcome

    @State private var starReveal = [false, false, false]
    @State private var showBanner = false

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                if !outcome.newlyUnlockedAchievementIDs.isEmpty {
                    achievementBanner
                        .padding(.top, outcome.newlyUnlockedAchievementIDs.isEmpty ? 0 : 6)
                }

                Text(outcome.won ? "Stage Cleared" : "Try Again")
                    .font(.title.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)

                Text(LevelPresentation.stageTitle(activity: activity, level: level))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appTextSecondary)

                Text(outcome.won ? "Great pacing—keep the streak alive." : "Adjust your tempo and give it another shot.")
                    .font(.body)
                    .foregroundStyle(Color.appTextSecondary)
                    .multilineTextAlignment(.center)

                starRow
                    .padding(.vertical, 8)

                statsCard

                VStack(spacing: 12) {
                    if outcome.won, level < AppStorage.levelCountValue() {
                        CasualPrimaryButton(title: "Next Stage") {
                            path.removeLast()
                            path.append(LevelRoute.play(activity: activity, difficulty: difficulty, level: level + 1))
                        }
                    }

                    CasualSecondaryButton(title: "Replay Stage") {
                        path.removeLast()
                        path.append(LevelRoute.play(activity: activity, difficulty: difficulty, level: level))
                    }

                    CasualSecondaryButton(title: "Back to Levels") {
                        path.removeLast()
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 24)
        }
        .mainTabBarBottomClearance()
        .appScreenBackground()
        .navigationBarBackButtonHidden(true)
        .onAppear {
            animateStars()
            if !outcome.newlyUnlockedAchievementIDs.isEmpty {
                withAnimation(.spring(response: 0.55, dampingFraction: 0.82).delay(0.35)) {
                    showBanner = true
                }
            }
        }
    }

    private var achievementBanner: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("New Highlight")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.appAccent)
            Text(bannerText)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.appTextPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appElevatedCardStyle(cornerRadius: 18)
        .shadow(color: Color.appAccent.opacity(0.35), radius: 14, y: 6)
        .offset(y: showBanner ? 0 : -120)
        .opacity(showBanner ? 1 : 0)
    }

    private var bannerText: String {
        let titles = store.achievementSnapshot().filter { row in
            outcome.newlyUnlockedAchievementIDs.contains(row.id)
        }
        .map(\.title)
        if titles.isEmpty {
            return "Fresh milestone unlocked."
        }
        return titles.joined(separator: ", ")
    }

    private var starRow: some View {
        HStack(spacing: 18) {
            ForEach(0 ..< 3, id: \.self) { index in
                ResultStarView(filled: index < outcome.stars)
                    .scaleEffect(starReveal[index] ? 1 : 0.3)
                    .opacity(starReveal[index] ? 1 : 0.2)
                    .shadow(color: Color.appAccent.opacity(starReveal[index] ? 0.65 : 0.0), radius: starReveal[index] ? 14 : 0)
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.68)
                            .delay(Double(index) * 0.15),
                        value: starReveal[index]
                    )
            }
        }
    }

    private var statsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Run Stats")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
            statLine(title: "Time", value: String(format: "%.1fs", outcome.durationSeconds))
            statLine(title: "Accuracy", value: String(format: "%.0f%%", outcome.accuracyPercent))
            statLine(title: "Outcome", value: outcome.won ? "Cleared" : "Incomplete")
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appElevatedCardStyle(cornerRadius: 20)
    }

    private func statLine(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(Color.appTextSecondary)
            Spacer()
            Text(value)
                .font(.headline.weight(.semibold))
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }

    private func animateStars() {
        for index in 0 ..< 3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.15) {
                if index < outcome.stars {
                    starReveal[index] = true
                } else {
                    starReveal[index] = true
                }
            }
        }
    }
}

private struct ResultStarView: View {
    let filled: Bool

    var body: some View {
        ZStack {
            StarShape()
                .stroke(Color.appAccent.opacity(0.45), lineWidth: 3)
                .frame(width: 52, height: 52)
            StarShape()
                .fill(
                    filled
                        ? LinearGradient(
                            colors: [Color.appAccent, Color.appPrimary.opacity(0.85)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : LinearGradient(
                            colors: [Color.appSurface.opacity(0.5), Color.appSurface.opacity(0.3)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                )
                .frame(width: 52, height: 52)
                .shadow(color: filled ? Color.appAccent.opacity(0.45) : .clear, radius: filled ? 10 : 0, y: 4)
        }
    }
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
