//
//  RewardsAndAchievementsView.swift
//  136KexmexcregrexPrellil
//

import SwiftUI

struct RewardsAndAchievementsView: View {
    @EnvironmentObject private var store: AppStorage

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                meritBlock

                Text("Achievements")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)

                Text("Complete goals across progress, mastery, and dedication. Everything unlocks from real play data.")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                let all = store.achievementSnapshot()
                let total = all.count
                let unlocked = all.filter(\.isUnlocked).count
                HStack {
                    Text("\(unlocked) / \(total) unlocked")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color.appAccent)
                    Spacer()
                }

                ForEach(AchievementCategory.allCases) { category in
                    categorySection(category: category, rows: all.filter { $0.category == category })
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 24)
        }
        .appScreenBackground()
        .navigationTitle("Rewards")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var meritBlock: some View {
        let mp = store.meritProgressSnapshot()
        return VStack(alignment: .leading, spacing: 14) {
            Text("Merit rank")
                .font(.title3.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)

            Text("Your rank grows with total stars earned across all activities—no extra economy, just proof of skill.")
                .font(.footnote)
                .foregroundStyle(Color.appTextSecondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(alignment: .center, spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(Color.appAccent.opacity(0.35), lineWidth: 6)
                        .frame(width: 72, height: 72)
                    Circle()
                        .trim(from: 0, to: CGFloat(mp.fractionToNext))
                        .stroke(Color.appPrimary, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 72, height: 72)
                    Text(shortRankLetter(mp.rank))
                        .font(.title2.weight(.heavy))
                        .foregroundStyle(Color.appTextPrimary)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text(mp.rank.displayTitle)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Color.appTextPrimary)
                    Text(mp.rank.tagline)
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    if let need = mp.starsToNextRank, let next = mp.rank.next() {
                        Text("Next: \(next.displayTitle) — \(need) more stars")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.appAccent)
                    } else {
                        Text("Top rank reached")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.appAccent)
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(16)
            .appElevatedCardStyle(cornerRadius: 20)

            HStack {
                Label("Total stars", systemImage: "star.fill")
                    .foregroundStyle(Color.appTextSecondary)
                Spacer()
                Text("\(mp.totalStars)")
                    .font(.headline.monospacedDigit().weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
            }
            .padding(.horizontal, 4)
        }
    }

    private func shortRankLetter(_ rank: MeritRank) -> String {
        String(rank.displayTitle.prefix(1))
    }

    private func categorySection(category: AchievementCategory, rows: [AchievementRow]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(category.displayTitle)
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)

            VStack(alignment: .leading, spacing: 4) {
                ForEach(rows) { row in
                    achievementRowView(row)
                }
            }
            .padding(14)
            .appElevatedCardStyle(cornerRadius: 18)
        }
    }

    private func achievementRowView(_ row: AchievementRow) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: row.isUnlocked ? "seal.fill" : "lock.fill")
                .foregroundStyle(row.isUnlocked ? Color.appAccent : Color.appTextSecondary.opacity(0.88))
                .font(.title3)
            VStack(alignment: .leading, spacing: 4) {
                Text(row.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary)
                Text(row.detail)
                    .font(.footnote)
                    .foregroundStyle(Color.appTextSecondary)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 8)
    }
}
