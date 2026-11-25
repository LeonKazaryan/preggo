//
//  HealthKitManager.swift
//  Preggo
//
//  Thin async/await wrapper around HealthKit for the three maternal
//  bio-markers: HRV (SDNN), resting heart rate, and respiratory rate.
//
//  All HKSampleQuery and HKStatisticsCollectionQuery callbacks are
//  bridged to Swift Concurrency via withCheckedThrowingContinuation so
//  that callers never touch HealthKit's callback-based API directly.
//
//  Required Info.plist keys:
//    NSHealthShareUsageDescription
//

import Foundation
import HealthKit

// MARK: - HealthKitError

/// Typed errors surfaced to callers of `HealthKitManager`.
enum HealthKitError: LocalizedError {
    /// HealthKit is not available on this device (e.g. iPad without Fitness).
    case notAvailable

    /// The user declined one or more requested permissions.
    case permissionDenied

    /// HealthKit returned no samples for the requested type and window.
    case dataUnavailable

    /// An underlying HealthKit query failed with the associated description.
    case queryFailed(String)

    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "Health data is not available on this device."
        case .permissionDenied:
            return "Please grant Health access in Settings > Privacy > Health > Preggo."
        case .dataUnavailable:
            return "No recent health data found. Wear your device for a full day first."
        case .queryFailed(let reason):
            return "Health query failed: \(reason)"
        }
    }
}

// MARK: - HealthKitManager

/// Singleton service that reads maternal bio-markers from HealthKit.
///
/// Typical call sequence:
/// ```swift
/// try await HealthKitManager.shared.requestPermissions()
/// let markers = try await HealthKitManager.shared.fetchTodayBioMarkers()
/// ```
final class HealthKitManager {

    // MARK: Singleton

    static let shared = HealthKitManager()
    private init() {}

    // MARK: Private Properties

    private let store = HKHealthStore()

    // Quantity types for the three maternal bio-markers.
    private let hrvType      = HKQuantityType(.heartRateVariabilitySDNN)
    private let rhrType      = HKQuantityType(.restingHeartRate)
    private let respType     = HKQuantityType(.respiratoryRate)

    // MARK: - Public API

    /// Requests read authorisation for HRV SDNN, resting heart rate, and
    /// respiratory rate. Must be called before any fetch methods.
    ///
    /// - Throws: `HealthKitError.notAvailable` when HealthKit is absent,
    ///           `HealthKitError.permissionDenied` when the user declines.
    func requestPermissions() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitError.notAvailable
        }

        let readTypes: Set<HKObjectType> = [hrvType, rhrType, respType]

        // HealthKit's authorization API doesn't distinguish "denied" from
        // "not determined" in the completion — we inspect share status after.
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            store.requestAuthorization(toShare: nil, read: readTypes) { success, error in
                if let error {
                    continuation.resume(throwing: HealthKitError.queryFailed(error.localizedDescription))
                } else if !success {
                    continuation.resume(throwing: HealthKitError.permissionDenied)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    /// Fetches the most recent reading of each bio-marker plus their 7-day
    /// rolling baselines and packages them into a `BioMarkerData` snapshot.
    ///
    /// - Returns: A populated `BioMarkerData` struct. Individual fields may
    ///   be `nil` when no samples exist for that type.
    /// - Throws: `HealthKitError` variants on HealthKit or permission failures.
    func fetchTodayBioMarkers() async throws -> BioMarkerData {
        // Units:
        //   HRV: milliseconds  → secondUnit(with: .milli)
        //   RHR: beats/min     → count().unitDivided(by: .minute())
        //   Resp: breaths/min  → same as RHR

        let hrvUnit  = HKUnit.secondUnit(with: .milli)
        let rhrUnit  = HKUnit.count().unitDivided(by: .minute())
        let respUnit = HKUnit.count().unitDivided(by: .minute())

        // Fetch the latest single sample and the 7-day baseline concurrently.
        async let hrv      = fetchLatestSample(for: hrvType,  unit: hrvUnit)
        async let rhr      = fetchLatestSample(for: rhrType,  unit: rhrUnit)
        async let resp     = fetchLatestSample(for: respType, unit: respUnit)
        async let hrvBase  = fetchSevenDayBaseline(for: hrvType,  unit: hrvUnit)
        async let rhrBase  = fetchSevenDayBaseline(for: rhrType,  unit: rhrUnit)
        async let respBase = fetchSevenDayBaseline(for: respType, unit: respUnit)

        return BioMarkerData(
            hrv: try await hrv,
            restingHeartRate: try await rhr,
            respiratoryRate: try await resp,
            recordedAt: Date(),
            hrvBaseline: try await hrvBase,
            rhrBaseline: try await rhrBase,
            respBaseline: try await respBase
        )
    }

    // MARK: - Demo Mode

    /// Returns a static snapshot of "unhealthy" bio-markers for demo/testing
    /// without requiring a real Apple Watch. All three markers deviate from
    /// their injected baselines in the clinically concerning direction.
    static func loadDemoData() -> BioMarkerData {
        BioMarkerData(
            hrv:              22.0,   // well below 7-day avg of 42 → autonomic stress
            restingHeartRate: 90.0,   // above 7-day max of 78 → elevated
            respiratoryRate:  20.0,   // above 7-day max of 18 → elevated
            recordedAt: Date(),
            hrvBaseline:  BaselineStats(avg: 42.0, min: 35.0, max: 55.0),
            rhrBaseline:  BaselineStats(avg: 72.0, min: 68.0, max: 78.0),
            respBaseline: BaselineStats(avg: 16.0, min: 14.0, max: 18.0)
        )
    }

    // MARK: - Private Helpers

    /// Returns the most recent quantity value for the given `HKQuantityType`,
    /// or `nil` when no samples are recorded.
    private func fetchLatestSample(
        for type: HKQuantityType,
        unit: HKUnit
    ) async throws -> Double? {

        // Sort descending so the first result is the newest sample.
        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierEndDate,
            ascending: false
        )

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error {
                    continuation.resume(
                        throwing: HealthKitError.queryFailed(error.localizedDescription)
                    )
                    return
                }

                guard let sample = samples?.first as? HKQuantitySample else {
                    // No data is a valid state — callers handle nil gracefully.
                    continuation.resume(returning: nil)
                    return
                }

                continuation.resume(returning: sample.quantity.doubleValue(for: unit))
            }

            store.execute(query)
        }
    }

    /// Computes descriptive statistics (avg / min / max) over the past 7 days
    /// for the given `HKQuantityType` using `HKStatisticsCollectionQuery`.
    ///
    /// Returns `nil` when no data exists in the window.
    private func fetchSevenDayBaseline(
        for type: HKQuantityType,
        unit: HKUnit
    ) async throws -> BaselineStats? {

        let calendar = Calendar.current
        let endDate  = Date()
        // Anchor the 7-day window to midnight of the current day.
        guard let startDate = calendar.date(byAdding: .day, value: -7, to: endDate) else {
            return nil
        }

        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )

        // One daily interval bucket; HealthKit aggregates each day's readings.
        guard let anchorDate = calendar.date(
            from: calendar.dateComponents([.year, .month, .day], from: endDate)
        ) else {
            return nil
        }

        let intervalComponents = DateComponents(day: 1)

        // Request average, minimum, and maximum in a single pass.
        let options: HKStatisticsOptions = [.discreteAverage, .discreteMin, .discreteMax]

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsCollectionQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: options,
                anchorDate: anchorDate,
                intervalComponents: intervalComponents
            )

            query.initialResultsHandler = { _, results, error in
                if let error {
                    continuation.resume(
                        throwing: HealthKitError.queryFailed(error.localizedDescription)
                    )
                    return
                }

                guard let collection = results else {
                    continuation.resume(returning: nil)
                    return
                }

                // Aggregate across all daily buckets to get the week-level stats.
                var totalAvg  = 0.0
                var overallMin = Double.greatestFiniteMagnitude
                var overallMax = -Double.greatestFiniteMagnitude
                var bucketCount = 0

                collection.enumerateStatistics(from: startDate, to: endDate) { stats, _ in
                    if let avg = stats.averageQuantity()?.doubleValue(for: unit) {
                        totalAvg += avg
                        bucketCount += 1
                    }
                    if let min = stats.minimumQuantity()?.doubleValue(for: unit) {
                        overallMin = Swift.min(overallMin, min)
                    }
                    if let max = stats.maximumQuantity()?.doubleValue(for: unit) {
                        overallMax = Swift.max(overallMax, max)
                    }
                }

                guard bucketCount > 0 else {
                    continuation.resume(returning: nil)
                    return
                }

                let baseline = BaselineStats(
                    avg: totalAvg / Double(bucketCount),
                    min: overallMin == Double.greatestFiniteMagnitude ? 0 : overallMin,
                    max: overallMax == -Double.greatestFiniteMagnitude ? 0 : overallMax
                )
                continuation.resume(returning: baseline)
            }

            store.execute(query)
        }
    }
}
