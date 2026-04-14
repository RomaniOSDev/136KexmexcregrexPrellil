//
//  SettingsView.swift
//  136KexmexcregrexPrellil
//

import StoreKit
import SwiftUI
import UIKit

struct SettingsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Support & legal")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.appTextSecondary)
                    .textCase(.uppercase)
                    .tracking(0.8)

                settingsButton(
                    title: "Rate us",
                    subtitle: "Leave a quick rating on the App Store",
                    systemImage: "star.fill"
                ) {
                    rateApp()
                }

                settingsButton(
                    title: "Privacy Policy",
                    subtitle: "How we handle data",
                    systemImage: "hand.raised.fill"
                ) {
                    if let url = AppLegalURL.privacyPolicy.url {
                        UIApplication.shared.open(url)
                    }
                }

                settingsButton(
                    title: "Terms of Use",
                    subtitle: "Conditions for using the app",
                    systemImage: "doc.text.fill"
                ) {
                    if let url = AppLegalURL.termsOfUse.url {
                        UIApplication.shared.open(url)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 24)
        }
        .appScreenBackground()
        .mainTabBarBottomClearance()
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func settingsButton(
        title: String,
        subtitle: String,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.appPrimary.opacity(0.2))
                        .frame(width: 48, height: 48)
                    Image(systemName: systemImage)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Color.appPrimary)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color.appTextPrimary)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
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
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
