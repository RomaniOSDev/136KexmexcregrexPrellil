//
//  GameHostView.swift
//  136KexmexcregrexPrellil
//

import SwiftUI

struct GameHostView: View {
    @EnvironmentObject private var store: AppStorage
    @Binding var path: NavigationPath
    let activity: ActivityKind
    let difficulty: Difficulty
    let level: Int

    var body: some View {
        Group {
            switch activity {
            case .colorSplash:
                ColorSplashView(
                    difficulty: difficulty,
                    level: level,
                    onFinish: { won, stars, duration, accuracy in
                        finishSession(won: won, stars: stars, duration: duration, accuracy: accuracy)
                    }
                )
            case .shapeShift:
                ShapeShiftView(
                    difficulty: difficulty,
                    level: level,
                    onFinish: { won, stars, duration, accuracy in
                        finishSession(won: won, stars: stars, duration: duration, accuracy: accuracy)
                    }
                )
            case .rhythmTap:
                RhythmTapView(
                    difficulty: difficulty,
                    level: level,
                    onFinish: { won, stars, duration, accuracy in
                        finishSession(won: won, stars: stars, duration: duration, accuracy: accuracy)
                    }
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .mainTabBarBottomClearance()
        .appScreenBackground()
        .navigationTitle(LevelPresentation.stageTitle(activity: activity, level: level))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Levels") {
                    if !path.isEmpty {
                        path.removeLast()
                    }
                }
            }
        }
    }

    private func finishSession(won: Bool, stars: Int, duration: Double, accuracy: Double) {
        let outcome = store.applySession(
            activity: activity,
            difficulty: difficulty,
            level: level,
            won: won,
            stars: stars,
            durationSeconds: duration,
            accuracyPercent: accuracy
        )

        if !path.isEmpty {
            path.removeLast()
        }
        path.append(LevelRoute.result(activity: activity, difficulty: difficulty, level: level, outcome: outcome))
    }
}
