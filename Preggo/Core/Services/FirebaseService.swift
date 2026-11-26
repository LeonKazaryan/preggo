//
//  FirebaseService.swift
//  Preggo
//
//  Firestore persistence layer for bio-markers and AI analysis history.
//  Writes go under users/{uid} where uid comes from Firebase anonymous auth.
//  If Firebase is not configured (no GoogleService-Info.plist), every call is a no-op.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

// MARK: - FirebaseService

final class FirebaseService {

    static let shared = FirebaseService()
    private init() {}

    /// True when FirebaseApp.configure() ran (GoogleService-Info.plist is in the bundle).
    static var isConfigured: Bool { FirebaseApp.app() != nil }

    private var db: Firestore { Firestore.firestore() }

    // MARK: - Bio-Markers

    func saveBioMarkers(_ data: BioMarkerData) async throws {
        guard Self.isConfigured else { return }
        let uid = try await currentUID()
        let payload = try encodeToDictionary(data)
        try await db.collection("users").document(uid).collection("biomarkers").addDocument(data: payload)
    }

    // MARK: - AI Analysis History

    func saveAnalysis(_ result: AIAnalysisResult, gestationalWeek: Int) async throws {
        guard Self.isConfigured else { return }
        let uid = try await currentUID()
        let payload: [String: Any] = [
            "riskLevel":            result.riskLevel.rawValue,
            "personalizedMessage":  result.personalizedMessage,
            "riskSummary":          result.riskSummary,
            "doctorTalkingPoints":  result.doctorTalkingPoints,
            "actionItems":          result.actionItems,
            "flaggedMarkers":       result.flaggedMarkers,
            "extractedLabValues":   result.extractedLabValues,
            "gestationalWeek":      gestationalWeek,
            "analyzedAt":           Timestamp(date: Date())
        ]
        try await db.collection("users").document(uid)
                    .collection("user_analysis").addDocument(data: payload)
    }

    // MARK: - Helpers

    /// Signs in anonymously on first use so Firestore rules can require request.auth.uid == uid.
    func currentUID() async throws -> String {
        if let uid = Auth.auth().currentUser?.uid { return uid }
        return try await Auth.auth().signInAnonymously().user.uid
    }

    private func encodeToDictionary<T: Encodable>(_ value: T) throws -> [String: Any] {
        let data = try JSONEncoder().encode(value)
        guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw EncodingError.invalidValue(value, .init(codingPath: [], debugDescription: "Not a dictionary."))
        }
        return dict
    }
}
