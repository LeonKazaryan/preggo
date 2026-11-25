//
//  OnboardingFlow.swift
//  Preggo
//
//  Multi-step onboarding container with warm, reassuring transitions.
//

import SwiftUI

struct OnboardingFlow: View {

    @Environment(AppState.self) private var appState
    @State private var vm = OnboardingViewModel()

    var body: some View {
        ZStack {
            Color.preggoSurface.ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress bar (hidden on welcome and completion)
                if vm.currentStep > 0 && vm.currentStep < vm.totalSteps - 1 {
                    OnboardingProgressBar(progress: vm.progress)
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                }

                // Step content
                TabView(selection: $vm.currentStep) {
                    WelcomeStepView(onContinue: { vm.next() })
                        .tag(0)

                    WeekSelectorStepView(vm: vm)
                        .tag(1)

                    MetricsStepView(vm: vm)
                        .tag(2)

                    RiskFactorsStepView(vm: vm)
                        .tag(3)

                    HealthKitPermissionStepView(vm: vm)
                        .tag(4)

                    CompletionStepView {
                        let profile = vm.buildProfile()
                        appState.completeOnboarding(profile: profile)
                    }
                    .tag(5)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.35), value: vm.currentStep)
            }
        }
    }
}

// MARK: - Progress Bar

private struct OnboardingProgressBar: View {
    let progress: Double

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.preggoNavy.opacity(0.08))
                    .frame(height: 6)

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.preggoRose)
                    .frame(width: geo.size.width * progress, height: 6)
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
        }
        .frame(height: 6)
    }
}
