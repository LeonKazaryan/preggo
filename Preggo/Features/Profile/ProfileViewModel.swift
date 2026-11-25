//
//  ProfileViewModel.swift
//  Preggo
//

import Foundation
import Observation

@Observable
@MainActor
final class ProfileViewModel {

    var appState: AppState?

    // Editable fields (mirrors UserProfile)
    var gestationalWeek: Int = 12
    var age: Int = 28
    var weightKg: Double = 65.0
    var heightCm: Double = 165.0
    var selectedRiskFactors: Set<RiskFactor> = []

    func load(from appState: AppState) {
        self.appState = appState
        if let profile = appState.userProfile {
            gestationalWeek = profile.currentGestationalWeek
            age = profile.age
            weightKg = profile.weightKg
            heightCm = profile.heightCm
            selectedRiskFactors = profile.riskFactors
        }
    }

    func saveChanges() {
        guard let appState else { return }
        var updated = appState.userProfile ?? UserProfile(
            gestationalWeekAtSetup: gestationalWeek,
            setupDate: Date(),
            age: age,
            weightKg: weightKg,
            heightCm: heightCm,
            riskFactors: selectedRiskFactors
        )
        // For existing profiles, update values but preserve setupDate
        updated = UserProfile(
            gestationalWeekAtSetup: gestationalWeek,
            setupDate: Date(), // reset to now so week advances correctly
            age: age,
            weightKg: weightKg,
            heightCm: heightCm,
            riskFactors: selectedRiskFactors
        )
        appState.userProfile = updated
    }

    func resetOnboarding() {
        appState?.resetOnboarding()
    }

    var bmi: Double {
        guard heightCm > 0 else { return 0 }
        let h = heightCm / 100.0
        return weightKg / (h * h)
    }
}
