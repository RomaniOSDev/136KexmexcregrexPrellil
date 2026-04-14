//
//  VisualStyle.swift
//  136KexmexcregrexPrellil
//
//  Shared gradients, elevation, and card chrome (palette from Assets + AppColor).
//

import SwiftUI

enum AppVisual {
    static let cardCorner: CGFloat = 22
    static let panelCorner: CGFloat = 18
    static let tabBarCorner: CGFloat = 28
    static let tabBarItemCorner: CGFloat = 16

    static var screenGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.appBackground,
                Color.appPrimary.opacity(0.08),
                Color.appAccent.opacity(0.06),
                Color.appBackground,
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var primaryButtonGradient: LinearGradient {
        LinearGradient(
            colors: [Color.appPrimary, Color.appPrimary.opacity(0.78)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var secondaryFillGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.appSurface.opacity(0.95),
                Color.appSurface.opacity(0.72),
                Color.appPrimary.opacity(0.05),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var cardBorderGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.appAccent.opacity(0.4),
                Color.appPrimary.opacity(0.22),
                Color.appAccent.opacity(0.15),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var surfaceSheen: LinearGradient {
        LinearGradient(
            colors: [
                Color.appSurface,
                Color.appSurface.opacity(0.9),
                Color.appPrimary.opacity(0.05),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Floating custom tab bar shell.
    static var tabBarShellGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.appSurface.opacity(0.99),
                Color.appSurface.opacity(0.82),
                Color.appPrimary.opacity(0.09),
                Color.appAccent.opacity(0.06),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Highlight behind the active tab icon.
    static var tabBarSelectionGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.appPrimary.opacity(0.32),
                Color.appAccent.opacity(0.24),
                Color.appPrimary.opacity(0.14),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

extension View {
    func appScreenBackground() -> some View {
        background(AppVisual.screenGradient.ignoresSafeArea())
    }

    /// Cards and large panels: sheen, depth, gradient hairline.
    func appElevatedCardStyle(cornerRadius: CGFloat = AppVisual.cardCorner) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(AppVisual.surfaceSheen)
                    .shadow(color: Color.appPrimary.opacity(0.14), radius: 16, x: 0, y: 8)
                    .shadow(color: Color.appAccent.opacity(0.1), radius: 6, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(AppVisual.cardBorderGradient, lineWidth: 1)
            )
    }

    /// Compact panels (HUD, stats, timelines).
    func appInsetPanelStyle(cornerRadius: CGFloat = AppVisual.panelCorner) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.appSurface.opacity(0.98),
                                Color.appSurface.opacity(0.85),
                                Color.appAccent.opacity(0.04),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color.appTextPrimary.opacity(0.07), radius: 12, x: 0, y: 5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(AppVisual.cardBorderGradient.opacity(0.55), lineWidth: 1)
            )
    }
}
