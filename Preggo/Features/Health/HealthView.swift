//
//  HealthView.swift
//  Preggo
//
//  Health tab: bio-markers, AI risk analysis, extracted lab values.
//  Refactored from MainDashboardView — now reads from AppState + DocumentStore.
//

import SwiftUI

struct HealthView: View {

    @Environment(AppState.self) private var appState
    @Environment(DocumentStore.self) private var documentStore
    @State private var vm = HealthViewModel()

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color.preggoSurface.ignoresSafeArea()

                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 16) {
                            BioMarkersCard(vm: vm)
                            AIInsightCard(vm: vm)
                                .id("aiCard")
                            if let analysis = vm.aiAnalysis,
                               !analysis.extractedLabValues.isEmpty {
                                ExtractedLabValuesCard(analysis: analysis)
                            }
                            Color.clear.frame(height: 20)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    }
                    // Bring the AI card into view so the loading state is visible right away.
                    .onChange(of: vm.isLoadingAI) { _, loading in
                        guard loading else { return }
                        withAnimation(.easeInOut(duration: 0.4)) {
                            proxy.scrollTo("aiCard", anchor: .top)
                        }
                    }
                }

                if let message = vm.errorMessage {
                    ErrorBanner(message: message) {
                        withAnimation(.easeOut) { vm.dismissError() }
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.preggoNavy, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 1) {
                        Text("HEALTH")
                            .font(.system(size: 18, weight: .bold))
                            .kerning(4)
                            .foregroundStyle(.white)
                        Text("Bio-Markers & AI Risk")
                            .font(.preggoCaption)
                            .kerning(1)
                            .foregroundStyle(Color.white.opacity(0.6))
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        vm.exportPDF(snapshot: HealthReportSnapshot(vm: vm, appState: appState))
                    } label: {
                        if vm.isExporting {
                            ProgressView().tint(.white).frame(width: 20, height: 20)
                        } else {
                            Image(systemName: "doc.badge.arrow.up")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.white)
                        }
                    }
                    .disabled(vm.aiAnalysis == nil || vm.isExporting)
                }
            }
            .sheet(item: $vm.exportURL) { url in
                ShareSheet(url: url)
            }
            .task {
                vm.appState = appState
                vm.documentStore = documentStore
                await vm.loadHealthData()
            }
            .onChange(of: appState.isDemoMode) { _, _ in
                Task {
                    vm.appState = appState
                    vm.documentStore = documentStore
                    await vm.loadHealthData()
                }
            }
            .animation(.easeInOut(duration: 0.3), value: vm.errorMessage)
        }
    }
}

// MARK: - Risk Color Helper

func riskColor(for level: AIAnalysisResult.RiskLevel) -> Color {
    switch level {
    case .low:      return .preggoSuccess
    case .moderate: return .preggoWarning
    case .high:     return Color(hex: "#E05252")
    case .critical: return Color(hex: "#C0392B")
    }
}

// MARK: - Bio-Markers Card

struct BioMarkersCard: View {
    @Bindable var vm: HealthViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("Bio-Markers", systemImage: "waveform.path.ecg")
                    .font(.preggoHeadline)
                    .foregroundStyle(Color.preggoNavy)
                Spacer()
                Text("Live")
                    .font(.preggoCaption)
                    .foregroundStyle(Color.preggoSuccess)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.preggoSuccess.opacity(0.12))
                    .clipShape(Capsule())
            }

            Divider().background(Color.preggoNavy.opacity(0.08))

            if vm.isLoadingHealth {
                loadingSkeleton
            } else if let markers = vm.bioMarkers {
                VStack(spacing: 12) {
                    BioMarkerRow(icon: "heart.fill", label: "HRV (SDNN)",
                                 value: markers.hrv.map { String(format: "%.0f ms", $0) },
                                 trend: markers.hrvTrend(), trendIsGoodWhenAbove: true)
                    BioMarkerRow(icon: "heart.circle.fill", label: "Resting HR",
                                 value: markers.restingHeartRate.map { String(format: "%.0f BPM", $0) },
                                 trend: markers.rhrTrend(), trendIsGoodWhenAbove: false)
                    BioMarkerRow(icon: "lungs.fill", label: "Resp. Rate",
                                 value: markers.respiratoryRate.map { String(format: "%.0f br/min", $0) },
                                 trend: markers.respTrend(), trendIsGoodWhenAbove: false)
                }
            } else {
                EmptyDataLabel(message: "No health data available.\nGrant Health permissions or use Demo Mode in Profile.")
            }

            Text("vs 7-day personal baseline")
                .font(.preggoCaption)
                .foregroundStyle(Color.preggoMuted)

            if vm.bioMarkers != nil {
                Button {
                    Task { await vm.runAIAnalysis() }
                } label: {
                    HStack(spacing: 8) {
                        if vm.isLoadingAI {
                            ProgressView()
                                .tint(.white)
                            Text("Analyzing…")
                                .fontWeight(.semibold)
                        } else {
                            Image(systemName: "waveform.and.magnifyingglass")
                            Text("Run AI Analysis")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.preggoNavy.opacity(vm.isLoadingAI ? 0.55 : 1))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .animation(.easeInOut(duration: 0.2), value: vm.isLoadingAI)
                }
                .disabled(vm.isLoadingAI)
            }
        }
        .padding(20)
        .cardStyle()
    }

    private var loadingSkeleton: some View {
        VStack(spacing: 12) {
            ForEach(0..<3, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.preggoMuted.opacity(0.15))
                    .frame(height: 44)
                    .shimmering()
            }
        }
    }
}

// MARK: - BioMarkerRow

struct BioMarkerRow: View {
    let icon: String
    let label: String
    let value: String?
    let trend: BioMarkerData.Trend
    let trendIsGoodWhenAbove: Bool

    private var trendSymbol: String {
        switch trend {
        case .above:   return "arrow.up"
        case .below:   return "arrow.down"
        case .normal:  return "minus"
        case .unknown: return "questionmark"
        }
    }

    private var trendColor: Color {
        switch trend {
        case .normal:  return .preggoSuccess
        case .unknown: return .preggoMuted
        case .above:   return trendIsGoodWhenAbove ? .preggoSuccess : .preggoWarning
        case .below:   return trendIsGoodWhenAbove ? .preggoWarning : .preggoSuccess
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(Color.preggoRose)
                .frame(width: 28)
            Text(label)
                .font(.preggoBody)
                .foregroundStyle(Color.preggoNavy)
            Spacer()
            if let value {
                Text(value)
                    .font(.preggoHeadline)
                    .foregroundStyle(Color.preggoNavy)
            } else {
                Text("—")
                    .font(.preggoHeadline)
                    .foregroundStyle(Color.preggoMuted)
            }
            Image(systemName: trendSymbol)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(trendColor)
                .frame(width: 20)
        }
        .padding(.vertical, 6)
    }
}

// MARK: - AI Insight Card

struct AIInsightCard: View {
    @Bindable var vm: HealthViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("AI Risk Center", systemImage: "waveform.and.magnifyingglass")
                    .font(.preggoHeadline)
                    .foregroundStyle(Color.preggoNavy)
                Spacer()
                Text("Grok")
                    .font(.preggoCaption)
                    .foregroundStyle(Color.preggoNavy.opacity(0.7))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.preggoNavy.opacity(0.08))
                    .clipShape(Capsule())
            }

            Divider().background(Color.preggoNavy.opacity(0.08))

            if vm.isLoadingAI {
                AIAnalyzingView()
            } else if let analysis = vm.aiAnalysis {
                PersonalizedMessageBanner(message: analysis.personalizedMessage, riskLevel: analysis.riskLevel)

                Divider().background(Color.preggoNavy.opacity(0.06))

                RiskGaugeView(riskLevel: analysis.riskLevel)
                    .frame(height: 130)

                ConfidenceIndexView(score: analysis.confidenceScore)

                Divider().background(Color.preggoNavy.opacity(0.06))

                sectionHeader(icon: "chart.line.uptrend.xyaxis", title: "Clinical Summary")
                Text(analysis.riskSummary)
                    .font(.preggoBody)
                    .foregroundStyle(Color.preggoNavy.opacity(0.85))
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)

                if !analysis.doctorTalkingPoints.isEmpty {
                    Divider().background(Color.preggoNavy.opacity(0.06))
                    sectionHeader(icon: "stethoscope", title: "Ask Your Doctor")
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(analysis.doctorTalkingPoints, id: \.self) { point in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "questionmark.circle.fill")
                                    .font(.system(size: 13))
                                    .foregroundStyle(Color.preggoRose)
                                    .padding(.top, 1)
                                Text(point)
                                    .font(.preggoCaption)
                                    .foregroundStyle(Color.preggoNavy.opacity(0.75))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }

                if !analysis.actionItems.isEmpty {
                    Divider().background(Color.preggoNavy.opacity(0.06))
                    sectionHeader(icon: "checklist", title: "Action Items")
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(analysis.actionItems, id: \.self) { item in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 13))
                                    .foregroundStyle(Color.preggoSuccess)
                                    .padding(.top, 1)
                                Text(item)
                                    .font(.preggoCaption)
                                    .foregroundStyle(Color.preggoNavy.opacity(0.75))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
            } else {
                EmptyDataLabel(
                    message: "No analysis yet. Load health data and tap 'Run AI Analysis'."
                )
            }
        }
        .padding(20)
        .cardStyle()
    }

    private func sectionHeader(icon: String, title: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.preggoNavy.opacity(0.5))
            Text(title.uppercased())
                .font(.system(size: 10, weight: .semibold))
                .kerning(1.5)
                .foregroundStyle(Color.preggoNavy.opacity(0.5))
        }
    }
}

// MARK: - AI Analyzing View

/// Loading state for the AI card: spinning ring, pulsing icon and step captions.
/// Everything is derived from TimelineView time, so no repeatForever animation state leaks out.
struct AIAnalyzingView: View {
    @State private var start = Date()

    private let steps = [
        "Reading your bio-markers…",
        "Scanning your lab reports…",
        "Correlating risk factors…",
        "Writing your personal summary…"
    ]
    private let stepDuration = 2.5

    var body: some View {
        TimelineView(.animation) { context in
            let elapsed = context.date.timeIntervalSince(start)
            let step = min(Int(elapsed / stepDuration), steps.count - 1)
            let angle = (elapsed.truncatingRemainder(dividingBy: 1.2) / 1.2) * 360
            let pulse = 1 + 0.08 * sin(elapsed * 3)

            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(Color.preggoRose.opacity(0.15), lineWidth: 6)
                    Circle()
                        .trim(from: 0, to: 0.3)
                        .stroke(Color.preggoRose, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .rotationEffect(.degrees(angle))
                    Image(systemName: "sparkles")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(Color.preggoRose)
                        .scaleEffect(pulse)
                }
                .frame(width: 72, height: 72)

                Text(steps[step])
                    .font(.preggoBody)
                    .foregroundStyle(Color.preggoNavy)
                    .id(step)
                    .transition(.opacity)

                HStack(spacing: 6) {
                    ForEach(steps.indices, id: \.self) { i in
                        Capsule()
                            .fill(i <= step ? Color.preggoRose : Color.preggoMuted.opacity(0.2))
                            .frame(width: i == step ? 18 : 6, height: 6)
                    }
                }

                Text("This usually takes a few seconds")
                    .font(.preggoCaption)
                    .foregroundStyle(Color.preggoMuted)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .animation(.easeInOut(duration: 0.35), value: step)
        }
    }
}

// MARK: - Confidence Index

/// 0–100 score from the model: how much it trusts its own assessment given the data it had.
struct ConfidenceIndexView: View {
    let score: Int

    private var color: Color {
        switch score {
        case 75...:   return .preggoSuccess
        case 50..<75: return .preggoWarning
        default:      return Color(hex: "#E05252")
        }
    }

    private var caption: String {
        switch score {
        case 75...:   return "High — enough data for a reliable assessment."
        case 50..<75: return "Medium — some data is missing. Scan lab reports for a sharper read."
        default:      return "Low — add Health data or scan lab reports and run again."
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("AI Confidence Index", systemImage: "checkmark.seal")
                    .font(.preggoCaption)
                    .foregroundStyle(Color.preggoNavy.opacity(0.7))
                Spacer()
                Text("\(score)%")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(color)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.preggoNavy.opacity(0.08))
                    Capsule()
                        .fill(color)
                        .frame(width: geo.size.width * CGFloat(score) / 100)
                }
            }
            .frame(height: 8)
            Text(caption)
                .font(.preggoCaption)
                .foregroundStyle(Color.preggoMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Personalized Message Banner

struct PersonalizedMessageBanner: View {
    let message: String
    let riskLevel: AIAnalysisResult.RiskLevel

    private var accentColor: Color {
        switch riskLevel {
        case .low:      return Color.preggoSuccess
        case .moderate: return Color.preggoRose
        case .high:     return Color(hex: "#E05252")
        case .critical: return Color(hex: "#C0392B")
        }
    }

    private var heartIcon: String {
        switch riskLevel {
        case .low:      return "heart.fill"
        case .moderate: return "heart.fill"
        case .high:     return "heart.slash.fill"
        case .critical: return "heart.slash.fill"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: heartIcon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(accentColor)
                Text("YOUR AI HEALTH UPDATE")
                    .font(.system(size: 10, weight: .semibold))
                    .kerning(1.5)
                    .foregroundStyle(accentColor)
            }
            Text(message)
                .font(.preggoBody)
                .foregroundStyle(Color.preggoNavy.opacity(0.9))
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(accentColor.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(accentColor.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Extracted Lab Values Card

struct ExtractedLabValuesCard: View {
    let analysis: AIAnalysisResult

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("Lab Results", systemImage: "doc.text.magnifyingglass")
                    .font(.preggoHeadline)
                    .foregroundStyle(Color.preggoNavy)
                Spacer()
                Text("AI Extracted")
                    .font(.preggoCaption)
                    .foregroundStyle(Color.preggoRose.opacity(0.9))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.preggoRose.opacity(0.1))
                    .clipShape(Capsule())
            }

            Divider().background(Color.preggoNavy.opacity(0.08))

            let flagged = Set(analysis.flaggedMarkers.map { $0.lowercased() })

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: 10
            ) {
                ForEach(analysis.extractedLabValues.keys.sorted(), id: \.self) { key in
                    if let value = analysis.extractedLabValues[key] {
                        LabValueCell(
                            label: key,
                            value: value,
                            isFlagged: flagged.contains(key.lowercased())
                        )
                    }
                }
            }
        }
        .padding(20)
        .cardStyle()
    }
}

// MARK: - LabValueCell

struct LabValueCell: View {
    let label: String
    let value: String
    var isFlagged: Bool = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.preggoCaption)
                    .foregroundStyle(isFlagged ? Color.red.opacity(0.75) : Color.preggoMuted)
                    .lineLimit(1)
                Text(value)
                    .font(.preggoBody)
                    .fontWeight(.medium)
                    .foregroundStyle(isFlagged ? Color(hex: "#C0392B") : Color.preggoNavy)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(isFlagged ? Color.red.opacity(0.06) : Color.preggoNavy.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(isFlagged ? Color.red.opacity(0.45) : Color.clear, lineWidth: 1)
            )

            if isFlagged {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.red)
                    .padding(4)
            }
        }
    }
}

// MARK: - Risk Gauge View

struct RiskGaugeView: View {
    let riskLevel: AIAnalysisResult.RiskLevel

    private var fillFraction: Double {
        switch riskLevel {
        case .low:      return 0.15
        case .moderate: return 0.45
        case .high:     return 0.75
        case .critical: return 0.95
        }
    }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let center = CGPoint(x: w / 2, y: h)
            let radius = min(w / 2, h) - 18

            ZStack {
                gaugeArc(center: center, radius: radius, from: 0, to: 1)
                    .stroke(Color.preggoNavy.opacity(0.10),
                            style: StrokeStyle(lineWidth: 14, lineCap: .round))

                gaugeArc(center: center, radius: radius, from: 0, to: fillFraction)
                    .stroke(
                        LinearGradient(
                            colors: [.preggoSuccess, Color.yellow, .preggoWarning, Color(hex: "#E05252")],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                    )

                let needleAngle = Angle.degrees(180 + 180 * fillFraction)
                let needleTip = CGPoint(
                    x: center.x + (radius - 8) * CGFloat(cos(needleAngle.radians)),
                    y: center.y + (radius - 8) * CGFloat(sin(needleAngle.radians))
                )
                Path { path in
                    path.move(to: center)
                    path.addLine(to: needleTip)
                }
                .stroke(Color.preggoNavy, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))

                Circle()
                    .fill(Color.preggoNavy)
                    .frame(width: 10, height: 10)
                    .position(center)

                VStack(spacing: 2) {
                    Text(riskLevel.rawValue.uppercased())
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(riskColor(for: riskLevel))
                    Text("Risk Level")
                        .font(.preggoCaption)
                        .foregroundStyle(Color.preggoMuted)
                }
                .position(x: center.x, y: center.y - radius * 0.5)

                Text("LOW")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color.preggoSuccess)
                    .position(x: center.x - radius + 4, y: center.y + 4)

                Text("CRITICAL")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color(hex: "#E05252"))
                    .position(x: center.x + radius - 18, y: center.y + 4)
            }
        }
    }

    private func gaugeArc(center: CGPoint, radius: CGFloat, from startFraction: Double, to endFraction: Double) -> Path {
        Path { path in
            let startDeg = 180.0 + 180.0 * startFraction
            let endDeg   = 180.0 + 180.0 * endFraction
            path.addArc(center: center, radius: radius,
                        startAngle: .degrees(startDeg), endAngle: .degrees(endDeg),
                        clockwise: false)
        }
    }
}

// MARK: - Health Report Snapshot (PDF source)

struct HealthReportSnapshot: View {
    let vm: HealthViewModel
    let appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Profile header
            let profile = appState.patientProfile
            VStack(alignment: .leading, spacing: 4) {
                Text("PREGGO Clinical Report")
                    .font(.system(size: 20, weight: .bold))
                Text("Week \(profile.gestationalWeek) | Age \(profile.age) | BMI \(String(format: "%.1f", profile.bmi))")
                    .font(.preggoBody)
                    .foregroundStyle(Color.preggoMuted)
                if !profile.riskFactors.isEmpty {
                    Text("Risk factors: \(profile.riskFactors.joined(separator: ", "))")
                        .font(.preggoCaption)
                        .foregroundStyle(Color.preggoMuted)
                }
            }
            .padding(.horizontal, 20)

            Divider()

            if let analysis = vm.aiAnalysis {
                RiskGaugeView(riskLevel: analysis.riskLevel)
                    .frame(height: 130)

                ConfidenceIndexView(score: analysis.confidenceScore)
                    .padding(.horizontal, 20)

                Divider()

                Text(analysis.riskSummary)
                    .font(.preggoBody)
                    .padding(.horizontal, 20)

                if !analysis.doctorTalkingPoints.isEmpty {
                    Divider()
                    Text("Doctor Talking Points")
                        .font(.preggoHeadline)
                        .padding(.horizontal, 20)
                    ForEach(analysis.doctorTalkingPoints, id: \.self) { point in
                        HStack(alignment: .top, spacing: 8) {
                            Text("•")
                            Text(point).font(.preggoBody)
                        }
                        .padding(.horizontal, 20)
                    }
                }

                if !analysis.actionItems.isEmpty {
                    Divider()
                    Text("Action Items")
                        .font(.preggoHeadline)
                        .padding(.horizontal, 20)
                    ForEach(analysis.actionItems, id: \.self) { item in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.preggoSuccess)
                            Text(item).font(.preggoBody)
                        }
                        .padding(.horizontal, 20)
                    }
                }

                if !analysis.extractedLabValues.isEmpty {
                    Divider()
                    Text("Lab Values (AI Extracted)")
                        .font(.preggoHeadline)
                        .padding(.horizontal, 20)
                    ForEach(analysis.extractedLabValues.keys.sorted(), id: \.self) { key in
                        if let val = analysis.extractedLabValues[key] {
                            HStack {
                                Text(key).font(.preggoBody)
                                Spacer()
                                Text(val).font(.preggoBody).fontWeight(.medium)
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }

                if let markers = vm.bioMarkers {
                    Divider()
                    Text("Bio-Markers at Time of Analysis")
                        .font(.preggoHeadline)
                        .padding(.horizontal, 20)
                    VStack(alignment: .leading, spacing: 6) {
                        if let hrv = markers.hrv {
                            Text("HRV (SDNN): \(String(format: "%.0f ms", hrv))")
                                .font(.preggoBody)
                        }
                        if let rhr = markers.restingHeartRate {
                            Text("Resting HR: \(String(format: "%.0f BPM", rhr))")
                                .font(.preggoBody)
                        }
                        if let resp = markers.respiratoryRate {
                            Text("Respiratory Rate: \(String(format: "%.0f br/min", resp))")
                                .font(.preggoBody)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .padding(.vertical, 20)
        .frame(width: 390)
        .background(Color.white)
    }
}

// MARK: - Shared Components

struct ErrorBanner: View {
    let message: String
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(Color.preggoWarning)
            Text(message)
                .font(.preggoCaption)
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.white.opacity(0.7))
            }
        }
        .padding(14)
        .background(Color.preggoNavy.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}

struct EmptyDataLabel: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.preggoBody)
            .foregroundStyle(Color.preggoMuted)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}

// MARK: - Shimmer

/// Opacity pulse instead of a sliding gradient: a repeatForever offset inside a
/// GeometryReader kept geometry animating and flooded the console on iOS 26+.
struct ShimmerModifier: ViewModifier {
    @State private var dimmed = false

    func body(content: Content) -> some View {
        content
            .opacity(dimmed ? 0.4 : 1)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    dimmed = true
                }
            }
    }
}

extension View {
    func shimmering() -> some View { modifier(ShimmerModifier()) }
}
