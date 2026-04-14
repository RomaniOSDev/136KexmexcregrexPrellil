//
//  ContentView.swift
//  136KexmexcregrexPrellil
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var store = AppStorage.shared

    var body: some View {
        Group {
            if store.hasSeenOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .environmentObject(store)
    }
}

#Preview {
    ContentView()
}
