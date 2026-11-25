//
//  OnboardingViewModel.swift
//  Preggo
//
//  Holds draft onboarding state. On completion, creates a UserProfile
//  and persists it through AppState.
//

import Foundation
import Observation

@Observable
@MainActor
final class OnboardingViewModel {

    // MARK: - Draft State

    var gestationalWeek: Int = 12
    var age: Int = 28
    var weightKg: Double = 65.0
    var heightCm: Double = 165.0
    var selectedRiskFactors: Set<RiskFactor> = []

    var healthKitGranted: Bool = false
    var healthKitError: String?

    // MARK: - Navigation

    var currentStep: Int = 0
    let totalSteps = 6 // 0-based: welcome(0), week(1), metrics(2), risk(3), healthkit(4), done(5)

    var canProceed: Bool {
        switch currentStep {
        case 0: return true
        case 1: return gestationalWeek >= 1 && gestationalWeek <= 42
        case 2: return age > 0 && weightKg > 0 && heightCm > 0
        case 3: return true // risk factors are optional
        case 4: return true // healthkit can be skipped
        case 5: return true
        default: return false
        }
    }

    var progress: Double {
        Double(currentStep) / Double(totalSteps - 1)
    }

    func next() {
        guard currentStep < totalSteps - 1 else { return }
        currentStep += 1
    }

    func back() {
        guard currentStep > 0 else { return }
        currentStep -= 1
    }

    // MARK: - HealthKit

    func requestHealthKit() async {
        do {
            try await HealthKitManager.shared.requestPermissions()
            healthKitGranted = true
        } catch {
            healthKitError = error.localizedDescription
        }
    }

    // MARK: - Completion

    func buildProfile() -> UserProfile {
        UserProfile(
            gestationalWeekAtSetup: gestationalWeek,
            setupDate: Date(),
            age: age,
            weightKg: weightKg,
            heightCm: heightCm,
            riskFactors: selectedRiskFactors
        )
    }
}
