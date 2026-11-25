//
//  ContentView.swift
//  Preggo
//
//  Root router: shows onboarding if not complete, otherwise shows tab bar.
//

import SwiftUI

struct ContentView: View {

    @Environment(AppState.self) private var appState

    var body: some View {
        if appState.hasCompletedOnboarding {
            MainTabView()
        } else {
            OnboardingFlow()
        }
    }
}

#Preview {
    ContentView()
        .environment(AppState())
}
