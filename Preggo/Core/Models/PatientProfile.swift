//
//  PatientProfile.swift
//  Preggo
//
//  Clinical context bundle passed to the AI analysis engine.
//  Enables the AI to produce gestational-week-appropriate risk assessments.
//

import Foundation

// MARK: - PatientProfile

struct PatientProfile {
    let gestationalWeek: Int
    let age: Int
    let weightKg: Double
    let heightCm: Double
    let riskFactors: [String]

    var bmi: Double {
        guard heightCm > 0 else { return 0 }
        let heightM = heightCm / 100.0
        return weightKg / (heightM * heightM)
    }

    /// Pre-built demo profile for competition/testing.
    static let demo = PatientProfile(
        gestationalWeek: 28,
        age: 32,
        weightKg: 68.0,
        heightCm: 165.0,
        riskFactors: ["IVF", "First Pregnancy"]
    )
}
