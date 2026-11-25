//
//  BioMarkerData.swift
//  Preggo
//
//  Domain model for wearable bio-marker readings captured from HealthKit.
//  High-risk pregnancy monitoring relies on detecting subtle deviations
//  from a patient's personal baseline, hence the paired BaselineStats fields.
//

import Foundation

// MARK: - BioMarkerData

/// A single point-in-time snapshot of the three key maternal bio-markers
/// alongside their 7-day rolling baselines.
struct BioMarkerData: Codable {
    /// Heart Rate Variability SDNN in milliseconds.
    /// Lower values signal autonomic stress; clinically relevant in pre-eclampsia monitoring.
    let hrv: Double?

    /// Resting Heart Rate in beats per minute.
    /// Sustained elevation (>20 BPM above baseline) may indicate infection or haemodynamic stress.
    let restingHeartRate: Double?

    /// Respiratory Rate in breaths per minute.
    /// Elevated rate is an early sign of pulmonary complications in pregnancy.
    let respiratoryRate: Double?

    /// Timestamp of the most recent individual sample used to populate this snapshot.
    let recordedAt: Date

    /// 7-day rolling statistics for HRV, used for personalised baseline comparison.
    let hrvBaseline: BaselineStats?

    /// 7-day rolling statistics for resting heart rate.
    let rhrBaseline: BaselineStats?

    /// 7-day rolling statistics for respiratory rate.
    let respBaseline: BaselineStats?
}

// MARK: - BaselineStats

/// Descriptive statistics computed over a rolling 7-day window.
struct BaselineStats: Codable {
    /// Mean value over the window period.
    let avg: Double
    /// Minimum recorded value in the window.
    let min: Double
    /// Maximum recorded value in the window.
    let max: Double
}

// MARK: - Trend Helpers

extension BioMarkerData {
    /// Directional trend of a bio-marker relative to its 7-day personal baseline.
    enum Trend {
        /// Current reading is above the baseline range — may warrant clinical attention.
        case above
        /// Current reading is below the baseline range.
        case below
        /// Current reading falls within the baseline range — normal.
        case normal
        /// Insufficient data to determine a trend (reading or baseline absent).
        case unknown
    }

    /// Derives the HRV trend.
    /// A *lower* HRV than baseline is concerning in maternal health, so "above"
    /// here means the value is higher than the baseline max (improved autonomic tone)
    /// and "below" means lower than baseline min (potential stress signal).
    func hrvTrend() -> Trend {
        guard let value = hrv, let baseline = hrvBaseline else { return .unknown }
        if value > baseline.max { return .above }
        if value < baseline.min { return .below }
        return .normal
    }

    /// Derives the resting heart rate trend.
    /// An elevated RHR above the personal maximum baseline is the clinically
    /// significant direction for maternal early-warning systems.
    func rhrTrend() -> Trend {
        guard let value = restingHeartRate, let baseline = rhrBaseline else { return .unknown }
        if value > baseline.max { return .above }
        if value < baseline.min { return .below }
        return .normal
    }

    /// Derives the respiratory rate trend.
    func respTrend() -> Trend {
        guard let value = respiratoryRate, let baseline = respBaseline else { return .unknown }
        if value > baseline.max { return .above }
        if value < baseline.min { return .below }
        return .normal
    }
}
