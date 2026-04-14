//
//  MainTabView.swift
//  136KexmexcregrexPrellil
//

import SwiftUI

struct MainTabView: View {
    @State private var selection = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            ZStack {
                HomeView()
                    .opacity(selection == 0 ? 1 : 0)
                    .allowsHitTesting(selection == 0)
                    .accessibilityHidden(selection != 0)
                    .zIndex(selection == 0 ? 1 : 0)
                ActivitiesRootView()
                    .opacity(selection == 1 ? 1 : 0)
                    .allowsHitTesting(selection == 1)
                    .accessibilityHidden(selection != 1)
                    .zIndex(selection == 1 ? 1 : 0)
                ProfileView()
                    .opacity(selection == 2 ? 1 : 0)
                    .allowsHitTesting(selection == 2)
                    .accessibilityHidden(selection != 2)
                    .zIndex(selection == 2 ? 1 : 0)
            }
           

            customTabBar
        }
        
    }

    private var customTabBar: some View {
        HStack(spacing: 4) {
            tabButton(title: "Home", systemImage: "house.fill", index: 0)
            tabButton(title: "Activities", systemImage: "square.grid.2x2.fill", index: 1)
            tabButton(title: "Profile", systemImage: "person.crop.circle", index: 2)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: AppVisual.tabBarCorner, style: .continuous)
                .fill(AppVisual.tabBarShellGradient)
                .shadow(color: Color.black.opacity(0.14), radius: 22, x: 0, y: 12)
                .shadow(color: Color.appPrimary.opacity(0.2), radius: 14, x: 0, y: 6)
                .shadow(color: Color.appAccent.opacity(0.12), radius: 8, x: 0, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppVisual.tabBarCorner, style: .continuous)
                .stroke(AppVisual.cardBorderGradient.opacity(0.95), lineWidth: 1)
        )
        .padding(.horizontal, 18)
    }

    private func tabButton(title: String, systemImage: String, index: Int) -> some View {
        let selected = selection == index
        return Button {
            withAnimation(.spring(response: 0.42, dampingFraction: 0.74)) {
                selection = index
            }
        } label: {
            VStack(spacing: 5) {
                ZStack {
                    if selected {
                        RoundedRectangle(cornerRadius: AppVisual.tabBarItemCorner, style: .continuous)
                            .fill(AppVisual.tabBarSelectionGradient)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppVisual.tabBarItemCorner, style: .continuous)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.42),
                                                Color.appPrimary.opacity(0.45),
                                                Color.appAccent.opacity(0.28),
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                            .frame(height: 44)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 6)
                            .shadow(color: Color.appPrimary.opacity(0.42), radius: 10, x: 0, y: 4)
                            .shadow(color: Color.appAccent.opacity(0.22), radius: 5, x: 0, y: 2)
                            .transition(.scale(scale: 0.88).combined(with: .opacity))
                    }
                    Image(systemName: systemImage)
                        .font(.system(size: 19, weight: .semibold))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(selected ? Color.appPrimary : Color.appTextSecondary)
                        .scaleEffect(selected ? 1.22 : 1.0)
                        .shadow(color: selected ? Color.appPrimary.opacity(0.4) : .clear, radius: selected ? 8 : 0, y: selected ? 2 : 0)
                }
                .frame(height: 46)
                .frame(maxWidth: .infinity)

                Text(title)
                    .font(.system(size: 10, weight: selected ? .bold : .semibold, design: .rounded))
                    .foregroundStyle(selected ? Color.appPrimary : Color.appTextSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .scaleEffect(selected ? 1.04 : 1.0)
            }
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity, minHeight: 52)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

extension View {
    /// Space for `safeAreaInset` tab bar so scroll content and buttons stay above it.
    func mainTabBarBottomClearance() -> some View {
        padding(.bottom, 100)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppStorage.shared)
}
