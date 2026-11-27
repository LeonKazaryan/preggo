//
//  HealthViewModel.swift
//  Preggo
//
//  Orchestrates the Health tab: bio-markers, AI risk analysis, PDF export.
//  Reads patient profile from AppState, document images from DocumentStore.
//

import Foundation
import SwiftUI
import Observation

@Observable
@MainActor
final class HealthViewModel {

    // MARK: - State

    var bioMarkers: BioMarkerData? = nil
    var aiAnalysis: AIAnalysisResult? = nil
    var isLoadingHealth: Bool = false
    var isLoadingAI: Bool = false
    var isExporting: Bool = false
    var errorMessage: String? = nil
    var exportURL: URL? = nil

    // MARK: - Dependencies (injected from view)

    var appState: AppState?
    var documentStore: DocumentStore?

    // MARK: - Health Data

    func loadHealthData() async {
        isLoadingHealth = true
        defer { isLoadingHealth = false }

        if appState?.isDemoMode == true {
            let demo = HealthKitManager.loadDemoData()
            bioMarkers = demo
            // Fire-and-forget: the iCloud save resolves only after the server acks, which
            // would keep the loading state up while offline.
            Task { try? await CloudSyncService.shared.saveBioMarkers(demo) }
            return
        }

        do {
            try await HealthKitManager.shared.requestPermissions()
            let markers = try await HealthKitManager.shared.fetchTodayBioMarkers()
            bioMarkers = markers
            Task { try? await CloudSyncService.shared.saveBioMarkers(markers) }
        } catch let error as HealthKitError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Health data unavailable: \(error.localizedDescription)"
        }
    }

    // MARK: - AI Analysis

    func runAIAnalysis() async {
        // Ignore repeat taps while a request is in flight.
        guard !isLoadingAI else { return }
        guard let markers = bioMarkers else {
            errorMessage = "Load your health data before running an analysis."
            return
        }

        isLoadingAI = true
        errorMessage = nil
        defer { isLoadingAI = false }

        let profile = appState?.patientProfile ?? .demo
        let documentImages = documentStore?.imageDataForAnalysis() ?? []

        do {
            let analysis = try await AnalysisEngine.shared.analyzeRisk(
                bioMarkers: markers,
                documentImages: documentImages,
                profile: profile
            )
            aiAnalysis = analysis

            // Share with AppState so Home tab and other tabs can display it
            appState?.lastAnalysis = analysis
            appState?.lastAnalysisDate = Date()
            appState?.lastAnalysisDocumentCount = documentImages.count

            Task {
                try? await CloudSyncService.shared.saveAnalysis(
                    analysis,
                    gestationalWeek: profile.gestationalWeek
                )
            }
        } catch {
            errorMessage = "AI analysis failed: \(error.localizedDescription)"
        }
    }

    // MARK: - PDF Export

    func exportPDF<V: View>(snapshot: V) {
        guard !isExporting else { return }
        isExporting = true
        defer { isExporting = false }
        exportURL = PDFExportService().exportToPDF(snapshot)
    }

    func dismissError() {
        errorMessage = nil
    }
}

// MARK: - URL: Identifiable (for .sheet(item:))

extension URL: @retroactive Identifiable {
    public var id: String { absoluteString }
}
