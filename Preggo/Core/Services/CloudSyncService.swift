//
//  CloudSyncService.swift
//  Preggo
//
//  Saves bio-markers and AI analysis history to the user's private iCloud
//  database (CloudKit). Each user only ever sees their own records.
//  Errors (e.g. not signed into iCloud) are left to callers, which ignore them.
//

import Foundation
import CloudKit

// MARK: - CloudSyncService

final class CloudSyncService {

    static let shared = CloudSyncService()
    private init() {}

    private let containerID = "iCloud.com.leonkazaryan.preggo"
    private var db: CKDatabase { CKContainer(identifier: containerID).privateCloudDatabase }

    // MARK: - Bio-Markers

    func saveBioMarkers(_ data: BioMarkerData) async throws {
        let record = CKRecord(recordType: "BioMarkers")
        record["hrv"] = data.hrv
        record["restingHeartRate"] = data.restingHeartRate
        record["respiratoryRate"] = data.respiratoryRate
        record["recordedAt"] = data.recordedAt
        // Baselines are nested structs; keep the full snapshot as JSON.
        record["json"] = try jsonString(data)
        _ = try await db.save(record)
    }

    // MARK: - AI Analysis History

    func saveAnalysis(_ result: AIAnalysisResult, gestationalWeek: Int) async throws {
        let record = CKRecord(recordType: "Analysis")
        record["riskLevel"]           = result.riskLevel.rawValue
        record["personalizedMessage"] = result.personalizedMessage
        record["riskSummary"]         = result.riskSummary
        record["doctorTalkingPoints"] = result.doctorTalkingPoints
        record["actionItems"]         = result.actionItems
        record["flaggedMarkers"]      = result.flaggedMarkers
        record["extractedLabValues"]  = try jsonString(result.extractedLabValues)
        record["gestationalWeek"]     = gestationalWeek
        record["confidenceScore"]     = result.confidenceScore
        record["analyzedAt"]          = Date()
        _ = try await db.save(record)
    }

    // MARK: - Helpers

    private func jsonString<T: Encodable>(_ value: T) throws -> String {
        String(decoding: try JSONEncoder().encode(value), as: UTF8.self)
    }
}
