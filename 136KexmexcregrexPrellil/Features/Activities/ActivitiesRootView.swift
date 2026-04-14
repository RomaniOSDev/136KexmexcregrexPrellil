//
//  ActivitiesRootView.swift
//  136KexmexcregrexPrellil
//

import SwiftUI

struct ActivitiesRootView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            ActivitiesHubView(path: $path)
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
    }
}

struct ActivitiesHubView: View {
    @Binding var path: NavigationPath

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Activities")
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(Color.appTextPrimary)

                    Text("Each route has its own rhythm. Choose one to pick difficulty and stages.")
                        .font(.body)
                        .foregroundStyle(Color.appTextSecondary)
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .appElevatedCardStyle()

                VStack(spacing: 12) {
                    ForEach(ActivityKind.allCases) { activity in
                        Button {
                            path.append(activity)
                        } label: {
                            activityListRow(activity)
                        }
                        .buttonStyle(ActivityHubCardButtonStyle())
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 24)
            .padding(.bottom, 60)
        }
        .appScreenBackground()
       // .mainTabBarBottomClearance()
        .navigationBarTitleDisplayMode(.inline)
    }

    private func activityListRow(_ activity: ActivityKind) -> some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: hubIconGradient(activity),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 64, height: 64)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.appTextPrimary.opacity(0.1), lineWidth: 1)
                )
                .overlay {
                    ActivityGlyph(activity: activity)
                        .frame(width: 36, height: 36)
                }
                .shadow(color: Color.appPrimary.opacity(0.2), radius: 8, y: 4)

            VStack(alignment: .leading, spacing: 6) {
                Text(activity.displayTitle)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary)
                Text(activity.shortBlurb)
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.headline.weight(.bold))
                .foregroundStyle(Color.appAccent)
                .padding(10)
                .background(Circle().fill(Color.appAccent.opacity(0.12)))
        }
        .padding(16)
        .appElevatedCardStyle()
    }

    private func hubIconGradient(_ activity: ActivityKind) -> [Color] {
        switch activity {
        case .colorSplash:
            return [Color.appPrimary.opacity(0.5), Color.appAccent.opacity(0.35)]
        case .shapeShift:
            return [Color.appAccent.opacity(0.45), Color.appPrimary.opacity(0.32)]
        case .rhythmTap:
            return [Color.appPrimary.opacity(0.38), Color.appAccent.opacity(0.42)]
        }
    }
}

private struct ActivityHubCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.94 : 1)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}
