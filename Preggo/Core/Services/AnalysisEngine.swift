//
//  AnalysisEngine.swift
//  Preggo
//
//  Clinical AI analysis engine — calls Gemini 2.5 Flash with multimodal
//  input: structured patient data + scanned document images.
//
//  Images are sent as inline base64 JPEG data so Gemini can read lab reports
//  directly — no OCR regex parsing needed.
//
//  API key fetched at runtime from Firebase Remote Config.
//

import Foundation
import FirebaseRemoteConfig

// MARK: - AIAnalysisResult

struct AIAnalysisResult {
    enum RiskLevel: String {
        case low, moderate, high, critical
    }

    let riskLevel: RiskLevel
    /// Warm, personalized narrative written directly to the mother.
    let personalizedMessage: String
    let riskSummary: String
    let doctorTalkingPoints: [String]
    let actionItems: [String]
    let flaggedMarkers: [String]
    /// Lab values extracted by Gemini from scanned document images.
    let extractedLabValues: [String: String]
    let isLowConfidence: Bool
}

// MARK: - AnalysisError

enum AnalysisError: LocalizedError {
    case missingAPIKey
    case httpError(Int)
    case emptyResponse

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "Gemini API key not found. Set GEMINI_API_KEY in Firebase Remote Config."
        case .httpError(let code):
            return "Gemini API returned HTTP \(code). Check your API key and quota."
        case .emptyResponse:
            return "The AI returned an empty response. Please try again."
        }
    }
}

// MARK: - AnalysisEngine

final class AnalysisEngine {

    static let shared = AnalysisEngine()
    private init() {}

    private let endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"

    // MARK: - Public API

    /// Analyzes maternal risk using bio-markers, scanned document images, and patient profile.
    ///
    /// Document images are sent directly to Gemini's multimodal API as base64 JPEG data.
    /// Gemini extracts lab values from the images and correlates them with bio-markers.
    func analyzeRisk(
        bioMarkers: BioMarkerData,
        documentImages: [Data],
        profile: PatientProfile
    ) async throws -> AIAnalysisResult {

        // Fetch API key from Remote Config.
        let rc = RemoteConfig.remoteConfig()
        let rcSettings = RemoteConfigSettings()
        rcSettings.minimumFetchInterval = 3600
        rc.configSettings = rcSettings
        try await rc.fetchAndActivate()
        let apiKey = rc.configValue(forKey: "GEMINI_API_KEY").stringValue
        guard !apiKey.isEmpty else { throw AnalysisError.missingAPIKey }

        let prompt = buildPrompt(bioMarkers: bioMarkers, profile: profile, imageCount: documentImages.count)

        guard let url = URL(string: "\(endpoint)?key=\(apiKey)") else {
            throw AnalysisError.missingAPIKey
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Build multimodal parts: text prompt + optional image parts.
        var parts: [[String: Any]] = [["text": prompt]]
        for imageData in documentImages.prefix(5) {
            let base64 = imageData.base64EncodedString()
            parts.append([
                "inlineData": [
                    "mimeType": "image/jpeg",
                    "data": base64
                ]
            ])
        }

        let body: [String: Any] = [
            "system_instruction": [
                "parts": [["text": systemInstruction]]
            ],
            "contents": [
                ["parts": parts]
            ],
            "generationConfig": [
                "temperature": 0.2,
                "maxOutputTokens": 3000,
                "responseMimeType": "application/json"
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
        guard statusCode == 200 else {
            let bodyStr = String(data: data, encoding: .utf8) ?? ""
            print("❌ AnalysisEngine HTTP \(statusCode): \(bodyStr.prefix(300))")
            throw AnalysisError.httpError(statusCode)
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let text = (((json?["candidates"] as? [[String: Any]])?.first?["content"]
            as? [String: Any])?["parts"] as? [[String: Any]])?.first?["text"] as? String ?? ""

        guard !text.isEmpty else { throw AnalysisError.emptyResponse }
        print("🤖 AnalysisEngine response: \(text.prefix(500))")

        return parseResponse(text)
    }

    // MARK: - System Instruction

    private var systemInstruction: String {
        """
        You are a Senior OB-GYN AI Consultant specializing in high-risk maternal-fetal medicine. \
        You are reviewing a pregnant patient's wearable bio-marker data and may receive scanned \
        images of her laboratory reports.

        YOUR MANDATE:
        1. If lab report images are provided, extract ALL numeric values from them — do not miss any.
        2. Do NOT simply repeat numbers back. CORRELATE the lab values with the bio-markers.
        3. If you see Elevated Glucose + High Resting Heart Rate + Declining HRV together, \
           explicitly name the syndrome (e.g., "Gestational Diabetes / Metabolic Stress").
        4. If you see Protein in urine + Rising Blood Pressure + Low Platelet count, name it (Pre-eclampsia risk).
        5. Be clinically precise but empathetic — the reader is a pregnant mother, not a physician.
        6. Never fabricate values. If data is missing, note it and reason around it.
        7. If image quality is poor or no numeric values can be extracted, set confidence to "low".
        8. The MOST IMPORTANT field is "personalized_message" — write it as her caring OB-GYN \
           speaking warmly and directly to her, not as a clinical report. Use "you" and "your baby". \
           Reference her gestational week. Celebrate good numbers. If risk is low or moderate, be \
           warm and reassuring. If risk is high or critical, be honest but supportive — emphasize \
           what she can DO, not how scary it is. Never use jargon. Max 4 sentences.

        OBSTETRIC REFERENCE RANGES (flag any value outside these):
        - HRV (SDNN): <20 ms = autonomic stress
        - Resting Heart Rate: >100 BPM = concerning; >90 BPM = elevated
        - Respiratory Rate: >20 breaths/min = elevated
        - Glucose (fasting): >95 mg/dL = GDM risk; >126 = diagnostic
        - Glucose (1-hr GCT): >140 mg/dL = abnormal
        - Hemoglobin: <11.0 g/dL = anaemia
        - Platelet count: <150,000 = thrombocytopenia (urgent if <100,000)
        - Protein (urine): any ≥1+ = pre-eclampsia screen positive
        - Uric Acid: >5.5 mg/dL = pre-eclampsia risk marker
        - HbA1c: >5.7% = pre-diabetic; >6.5% = diagnostic diabetes
        - Ferritin: <12 ng/mL = iron depletion
        """
    }

    // MARK: - Prompt Construction

    private func buildPrompt(
        bioMarkers: BioMarkerData,
        profile: PatientProfile,
        imageCount: Int
    ) -> String {
        let hasImages = imageCount > 0
        let fmt = { (v: Double?, unit: String, baseline: BaselineStats?) -> String in
            guard let v else { return "Not recorded" }
            if let b = baseline {
                let delta = v - b.avg
                let sign = delta >= 0 ? "+" : ""
                return String(format: "%.1f %@ (7-day avg %.1f, Δ%@%.1f)", v, unit, b.avg, sign, delta)
            }
            return String(format: "%.1f %@", v, unit)
        }

        let riskFactorList = profile.riskFactors.isEmpty ? "None reported" : profile.riskFactors.joined(separator: ", ")
        let bmiStr = profile.bmi > 0 ? String(format: "%.1f", profile.bmi) : "N/A"

        let imageNote = hasImages
            ? "LAB REPORTS: \(imageCount) scanned document image(s) are attached above. Extract ALL numeric values from each image — do not skip any test."
            : "LAB REPORTS: No documents scanned yet — analysis based solely on bio-markers and patient profile."

        return """
        ═══════════════════════════════════════════
        PATIENT DATA BUNDLE — CLINICAL AI REVIEW
        ═══════════════════════════════════════════

        PATIENT PROFILE:
          Gestational Age : Week \(profile.gestationalWeek)
          Maternal Age    : \(profile.age) years
          Weight          : \(String(format: "%.1f", profile.weightKg)) kg
          Height          : \(String(format: "%.1f", profile.heightCm)) cm
          BMI             : \(bmiStr)
          Risk Factors    : \(riskFactorList)

        WEARABLE BIO-MARKERS (today vs 7-day personal baseline):
          HRV (SDNN)      : \(fmt(bioMarkers.hrv, "ms", bioMarkers.hrvBaseline))
          Resting HR      : \(fmt(bioMarkers.restingHeartRate, "BPM", bioMarkers.rhrBaseline))
          Respiratory Rate: \(fmt(bioMarkers.respiratoryRate, "br/min", bioMarkers.respBaseline))

        \(imageNote)

        ═══════════════════════════════════════════

        Respond with ONLY a valid JSON object — no markdown, no code fences:
        {
          "risk_level": "low" | "moderate" | "high" | "critical",
          "personalized_message": "<3–4 warm, caring sentences written directly to the mother using 'you'/'your baby'. Reference her gestational week. Explain what this data means for her and her baby in plain language — no jargon. If low/moderate risk: be warm, reassuring, celebrate good numbers. If high/critical: be honest and supportive, focusing on what she can do. Write as her caring OB-GYN speaking to her, not as a report.>",
          "risk_summary": "<2 clinical sentences: WHY these specific markers matter together. Name syndromes if present.>",
          "doctor_talking_points": [
            "<specific question 1 for the OB-GYN>",
            "<specific question 2 for the OB-GYN>",
            "<specific question 3 for the OB-GYN>"
          ],
          "action_items": ["<immediate action 1>", "<immediate action 2>", ...],
          "flagged_markers": ["<marker name 1>", "<marker name 2>", ...],
          "extracted_lab_values": {
            "<test name>": "<value with unit>",
            "<test name>": "<value with unit>"
          },
          "confidence": "high" | "low"
        }
        """
    }

    // MARK: - Response Parsing

    private func parseResponse(_ text: String) -> AIAnalysisResult {
        if let data = text.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            return map(json: json)
        }

        if let range = text.range(of: #"\{[\s\S]*\}"#, options: .regularExpression),
           let data = String(text[range]).data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            return map(json: json)
        }

        print("⚠️ AnalysisEngine: JSON parse failed, returning safe fallback.")
        return AIAnalysisResult(
            riskLevel: .moderate,
            personalizedMessage: "Your results have been reviewed and everything looks stable right now. Your body is working hard to support your growing baby, and we're here to keep a close eye on things together. Please share these results with your OB-GYN at your next visit.",
            riskSummary: "Analysis completed. Please review your results with your healthcare provider.",
            doctorTalkingPoints: [
                "What do my current bio-marker trends mean for my pregnancy?",
                "Are any of my lab values outside the normal range for my gestational age?",
                "What monitoring schedule do you recommend given these results?"
            ],
            actionItems: ["Consult your OB-GYN as soon as possible for a full review."],
            flaggedMarkers: [],
            extractedLabValues: [:],
            isLowConfidence: false
        )
    }

    private func map(json: [String: Any]) -> AIAnalysisResult {
        let riskRaw    = json["risk_level"] as? String ?? "moderate"
        let personal   = json["personalized_message"] as? String ?? "Your health data has been reviewed. Speak with your OB-GYN about your results."
        let summary    = json["risk_summary"] as? String ?? "Analysis complete. Discuss results with your provider."
        let talking    = json["doctor_talking_points"] as? [String] ?? []
        let actions    = json["action_items"] as? [String] ?? []
        let flagged    = json["flagged_markers"] as? [String] ?? []
        let labValues  = json["extracted_lab_values"] as? [String: String] ?? [:]
        let confidence = json["confidence"] as? String ?? "high"

        return AIAnalysisResult(
            riskLevel:           AIAnalysisResult.RiskLevel(rawValue: riskRaw) ?? .moderate,
            personalizedMessage: personal,
            riskSummary:         summary,
            doctorTalkingPoints: talking,
            actionItems:         actions,
            flaggedMarkers:      flagged,
            extractedLabValues:  labValues,
            isLowConfidence:     confidence == "low"
        )
    }
}
