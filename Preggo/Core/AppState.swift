//
//  AppState.swift
//  Preggo
//
//  Root-level observable state injected via .environment() from PreggoApp.
//  Owns onboarding completion flag and the user profile.
//

import Foundation
import Observation

@Observable
@MainActor
final class AppState {

    // MARK: - Onboarding

    var hasCompletedOnboarding: Bool {
        didSet { UserDefaults.standard.set(hasCompletedOnboarding, forKey: "preggo.onboardingComplete") }
    }

    // MARK: - User Profile

    var userProfile: UserProfile? {
        didSet { userProfile?.save() }
    }

    /// Patient profile for the AI engine. Falls back to demo if no profile set.
    var patientProfile: PatientProfile {
        userProfile?.toPatientProfile() ?? .demo
    }

    // MARK: - Shared Analysis State (readable from Home + Health tabs)

    var lastAnalysis: AIAnalysisResult?
    var lastAnalysisDate: Date?
    /// How many documents were included in the last AI analysis run.
    var lastAnalysisDocumentCount: Int = 0

    // MARK: - Demo Mode (shared across tabs)

    var isDemoMode: Bool = false

    // MARK: - Init

    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "preggo.onboardingComplete")
        self.userProfile = UserProfile.load()
    }

    // MARK: - Actions

    func completeOnboarding(profile: UserProfile) {
        self.userProfile = profile
        profile.save()
        self.hasCompletedOnboarding = true
    }

    func resetOnboarding() {
        hasCompletedOnboarding = false
        userProfile = nil
        UserProfile.clear()
    }
}
