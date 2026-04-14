//
//  LevelHubView.swift
//  136KexmexcregrexPrellil
//

import SwiftUI

struct LevelHubView: View {
    @EnvironmentObject private var store: AppStorage
    let activity: ActivityKind
    @Binding var path: NavigationPath

    @State private var difficulty: Difficulty = .easy

    private var gridColumns: [GridItem] {
        [GridItem(.adaptive(minimum: 104), spacing: 12)]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(activity.displayTitle)
                    .font(.title.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)

                Text(activity.shortBlurb)
                    .font(.body)
                    .foregroundStyle(Color.appTextSecondary)

                difficultyPicker

                ForEach(LevelChapter.allCases) { chapter in
                    chapterBlock(chapter: chapter)
                }

                if store.allLevelsCleared(activity: activity, difficulty: difficulty) {
                    completionBanner
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .mainTabBarBottomClearance()
        .appScreenBackground()
        .navigationBarTitleDisplayMode(.inline)
    }

    private var difficultyPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Difficulty")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
            HStack(spacing: 10) {
                ForEach(Difficulty.allCases) { diff in
                    Button {
                        withAnimation(.easeInOut(duration: 0.22)) {
                            difficulty = diff
                        }
                    } label: {
                        Text(diff.displayTitle)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(difficulty == diff ? Color.appTextPrimary : Color.appTextSecondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .background(
                                Group {
                                    if difficulty == diff {
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .fill(AppVisual.primaryButtonGradient)
                                            .shadow(color: Color.appPrimary.opacity(0.35), radius: 8, y: 4)
                                    } else {
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .fill(AppVisual.secondaryFillGradient)
                                    }
                                }
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(
                                        difficulty == diff
                                            ? Color.appTextPrimary.opacity(0.12)
                                            : Color.appAccent.opacity(0.2),
                                        lineWidth: 1
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func chapterBlock(chapter: LevelChapter) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            chapterHeader(chapter: chapter)

            LazyVGrid(columns: gridColumns, spacing: 12) {
                ForEach(Array(chapter.levelRange), id: \.self) { level in
                    levelCell(level: level, chapter: chapter)
                }
            }
        }
    }

    private func chapterHeader(chapter: LevelChapter) -> some View {
        HStack(alignment: .top, spacing: 12) {
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(chapterBarColor(chapter))
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline) {
                    Text(chapter.title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color.appTextPrimary)
                    Spacer(minLength: 8)
                    Text(chapter.rangeLabel)
                        .font(.caption.weight(.semibold).monospacedDigit())
                        .foregroundStyle(Color.appTextSecondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule(style: .continuous)
                                .fill(Color.appSurface.opacity(0.65))
                        )
                }
                Text(chapter.blurb)
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            chapterHeaderTint(chapter),
                            chapterHeaderTint(chapter).opacity(0.45),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.appPrimary.opacity(0.1), radius: 12, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppVisual.cardBorderGradient.opacity(0.55), lineWidth: 1)
        )
    }

    private func levelCell(level: Int, chapter: LevelChapter) -> some View {
        let unlocked = store.isLevelUnlocked(activity: activity, difficulty: difficulty, level: level)
        let stars = store.stars(activity: activity, difficulty: difficulty, level: level)
        let stage = LevelPresentation.stageTitle(activity: activity, level: level)
        let ordinal = LevelPresentation.stageOrdinal(level)

        return Button {
            guard unlocked else { return }
            path.append(LevelRoute.play(activity: activity, difficulty: difficulty, level: level))
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Stage \(ordinal)")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Color.appTextSecondary)
                    Spacer(minLength: 4)
                    if !unlocked {
                        Image(systemName: "lock.fill")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }

                ZStack(alignment: .center) {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(unlocked ? Color.appSurface : Color.appSurface.opacity(0.35))
                    if unlocked {
                        Text(stage)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(Color.appTextPrimary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(3)
                            .minimumScaleFactor(0.75)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(10)
                    } else {
                        Text(stage)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.appTextSecondary.opacity(0.78))
                            .multilineTextAlignment(.leading)
                            .lineLimit(3)
                            .minimumScaleFactor(0.75)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(10)
                    }
                }
                .frame(minHeight: 72, alignment: .center)

                HStack(spacing: 4) {
                    ForEach(0 ..< 3, id: \.self) { idx in
                        Image(systemName: idx < stars ? "star.fill" : "star")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(idx < stars ? Color.appAccent : Color.appTextSecondary.opacity(0.88))
                    }
                }
                .frame(minHeight: 16)
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(AppVisual.surfaceSheen)
                    .shadow(color: Color.appPrimary.opacity(unlocked ? 0.12 : 0.05), radius: 10, x: 0, y: 5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(chapterStroke(chapter).opacity(unlocked ? 1 : 0.22), lineWidth: 1.5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(AppVisual.cardBorderGradient.opacity(unlocked ? 0.35 : 0.12), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Stage \(level). \(stage). \(unlocked ? "Unlocked" : "Locked")")
    }

    private func chapterBarColor(_ chapter: LevelChapter) -> Color {
        switch chapter {
        case .shallows: return Color.appPrimary
        case .midChannel: return Color.appAccent
        case .highCrest: return Color.appAccent.opacity(0.95)
        }
    }

    private func chapterHeaderTint(_ chapter: LevelChapter) -> Color {
        switch chapter {
        case .shallows: return Color.appPrimary.opacity(0.11)
        case .midChannel: return Color.appAccent.opacity(0.1)
        case .highCrest: return Color.appAccent.opacity(0.14)
        }
    }

    private func chapterStroke(_ chapter: LevelChapter) -> Color {
        switch chapter {
        case .shallows: return Color.appPrimary.opacity(0.55)
        case .midChannel: return Color.appAccent.opacity(0.55)
        case .highCrest: return Color.appAccent.opacity(0.75)
        }
    }

    private var completionBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.title3.weight(.bold))
                .foregroundStyle(Color.appAccent)
            Text("You cleared every stage on this difficulty. Try another tier for fresh pacing.")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.appTextPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appElevatedCardStyle(cornerRadius: 18)
    }
}
