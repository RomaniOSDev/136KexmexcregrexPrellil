//
//  ProfileView.swift
//  136KexmexcregrexPrellil
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var store: AppStorage
    @State private var showResetConfirm = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Spotlight")
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(Color.appTextPrimary)

                    Text("Review merit rank, achievements, and session stats. All rewards come from stars and honest milestones.")
                        .font(.body)
                        .foregroundStyle(Color.appTextSecondary)

                    meritSummaryCard

                    NavigationLink {
                        RewardsAndAchievementsView()
                    } label: {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(Color.appPrimary.opacity(0.22))
                                    .frame(width: 48, height: 48)
                                Image(systemName: "gift.fill")
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(Color.appPrimary)
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Rewards & Achievements")
                                    .font(.headline.weight(.semibold))
                                    .foregroundStyle(Color.appTextPrimary)
                                Text("\(store.unlockedAchievementCount()) of \(store.achievementSnapshot().count) milestones unlocked")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.appTextSecondary)
                            }
                            Spacer(minLength: 0)
                            Image(systemName: "chevron.right")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(Color.appAccent)
                        }
                        .padding(16)
                        .appElevatedCardStyle()
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        SettingsView()
                    } label: {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(Color.appAccent.opacity(0.18))
                                    .frame(width: 48, height: 48)
                                Image(systemName: "gearshape.fill")
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(Color.appAccent)
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Settings")
                                    .font(.headline.weight(.semibold))
                                    .foregroundStyle(Color.appTextPrimary)
                                Text("Rate, privacy, and terms")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.appTextSecondary)
                            }
                            Spacer(minLength: 0)
                            Image(systemName: "chevron.right")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(Color.appAccent)
                        }
                        .padding(16)
                        .appElevatedCardStyle()
                    }
                    .buttonStyle(.plain)

                    statsSection

                    VStack(spacing: 12) {
                        CasualPrimaryButton(title: "Reset All Progress") {
                            showResetConfirm = true
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 24)
                .padding(.bottom, 60)
            }
            //.mainTabBarBottomClearance()
            .appScreenBackground()
            .navigationBarTitleDisplayMode(.inline)
            .alert("Reset everything?", isPresented: $showResetConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    store.resetAllProgress()
                }
            } message: {
                Text("This clears stars, merit data, achievements, unlocks, stats, and onboarding. It cannot be undone.")
            }
            .onReceive(NotificationCenter.default.publisher(for: .appProgressDidReset)) { _ in
                showResetConfirm = false
            }
        }
    }

    private var meritSummaryCard: some View {
        let mp = store.meritProgressSnapshot()
        return VStack(alignment: .leading, spacing: 12) {
            Text("Merit rank")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
            HStack(spacing: 12) {
                Text(mp.rank.displayTitle)
                    .font(.title2.weight(.heavy))
                    .foregroundStyle(Color.appPrimary)
                Text("·")
                    .foregroundStyle(Color.appTextSecondary)
                Text("\(mp.totalStars) stars")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary)
            }
            if let need = mp.starsToNextRank, let next = mp.rank.next() {
                Text("Reach \(next.displayTitle) — \(need) stars to go")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color.appTextSecondary)
            } else {
                Text("Highest merit band unlocked")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color.appAccent)
            }
            ProgressView(value: mp.fractionToNext, total: 1)
                .tint(Color.appAccent)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appElevatedCardStyle()
    }

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Statistics")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)

            statRow(title: "Total play time", value: formattedTime(store.totalPlaySeconds))
            statRow(title: "Finished sessions", value: "\(store.sessionsFinished)")
            statRow(title: "Wins", value: "\(store.totalWins)")
            statRow(title: "Stars collected", value: "\(store.totalStarsSum())")

            if store.sessionsFinished == 0 {
                Text("Play a stage to start filling these numbers.")
                    .font(.footnote)
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appElevatedCardStyle()
    }

    private func statRow(title: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .foregroundStyle(Color.appTextSecondary)
            Spacer()
            Text(value)
                .font(.headline.weight(.semibold))
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.vertical, 4)
    }

    private func formattedTime(_ seconds: Double) -> String {
        let total = Int(max(0, seconds))
        let minutes = total / 60
        let secs = total % 60
        return String(format: "%dm %02ds", minutes, secs)
    }
}
