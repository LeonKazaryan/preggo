//
//  FirebaseService.swift
//  Preggo
//
//  Firestore persistence layer for bio-markers and AI analysis history.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

// MARK: - FirebaseService

final class FirebaseService {

    static let shared = FirebaseService()
    private init() {}

    private let db = Firestore.firestore()
    private let anonymousUIDKey = "preggo.anonymous.uid"

    // MARK: - Bio-Markers

    func saveBioMarkers(_ data: BioMarkerData) async throws {
        let uid = try currentUID()
        let payload = try encodeToDictionary(data)
        try await db.collection("users").document(uid).collection("biomarkers").addDocument(data: payload)
    }

    // MARK: - AI Analysis History

    func saveAnalysis(_ result: AIAnalysisResult, gestationalWeek: Int) async throws {
        let uid = try currentUID()
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

    func currentUID() throws -> String {
        if let uid = Auth.auth().currentUser?.uid { return uid }
        let defaults = UserDefaults.standard
        if let existing = defaults.string(forKey: anonymousUIDKey) { return existing }
        let new = UUID().uuidString
        defaults.set(new, forKey: anonymousUIDKey)
        return new
    }

    private func encodeToDictionary<T: Encodable>(_ value: T) throws -> [String: Any] {
        let data = try JSONEncoder().encode(value)
        guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw EncodingError.invalidValue(value, .init(codingPath: [], debugDescription: "Not a dictionary."))
        }
        return dict
    }
}
