//
//  UserProfile.swift
//  Preggo
//
//  User's pregnancy profile collected during onboarding.
//  Persisted to UserDefaults as JSON for privacy-first local storage.
//

import Foundation

// MARK: - RiskFactor

enum RiskFactor: String, CaseIterable, Codable, Identifiable {
    case ivf = "IVF"
    case twins = "Twins"
    case gdmHistory = "GDM History"
    case hypertension = "Hypertension"
    case firstPregnancy = "First Pregnancy"
    case advancedMaternalAge = "Advanced Maternal Age"
    case previousPreeclampsia = "Previous Pre-eclampsia"
    case thyroidDisorder = "Thyroid Disorder"

    var id: String { rawValue }

    var displayName: String { rawValue }

    var icon: String {
        switch self {
        case .ivf:                    return "syringe.fill"
        case .twins:                  return "person.2.fill"
        case .gdmHistory:             return "drop.fill"
        case .hypertension:           return "heart.fill"
        case .firstPregnancy:         return "star.fill"
        case .advancedMaternalAge:    return "calendar.badge.clock"
        case .previousPreeclampsia:   return "exclamationmark.triangle.fill"
        case .thyroidDisorder:        return "bolt.heart.fill"
        }
    }
}

// MARK: - UserProfile

struct UserProfile: Codable {
    var gestationalWeekAtSetup: Int
    var setupDate: Date
    var age: Int
    var weightKg: Double
    var heightCm: Double
    var riskFactors: Set<RiskFactor>

    /// Computes the current gestational week based on elapsed time since setup.
    var currentGestationalWeek: Int {
        let elapsed = Calendar.current.dateComponents([.weekOfYear], from: setupDate, to: Date())
        let weeks = gestationalWeekAtSetup + (elapsed.weekOfYear ?? 0)
        return min(max(weeks, 1), 42)
    }

    /// BMI computed from weight and height.
    var bmi: Double {
        guard heightCm > 0 else { return 0 }
        let heightM = heightCm / 100.0
        return weightKg / (heightM * heightM)
    }

    /// Converts to `PatientProfile` for backward-compat with AnalysisEngine.
    func toPatientProfile() -> PatientProfile {
        PatientProfile(
            gestationalWeek: currentGestationalWeek,
            age: age,
            weightKg: weightKg,
            heightCm: heightCm,
            riskFactors: riskFactors.map(\.rawValue)
        )
    }

    // MARK: - Persistence

    private static let storageKey = "preggo.userProfile"

    func save() {
        guard let data = try? JSONEncoder().encode(self) else { return }
        UserDefaults.standard.set(data, forKey: Self.storageKey)
    }

    static func load() -> UserProfile? {
        guard let data = UserDefaults.standard.data(forKey: Self.storageKey),
              let profile = try? JSONDecoder().decode(UserProfile.self, from: data)
        else { return nil }
        return profile
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
}
