//
//  HomeView.swift
//  Preggo
//
//  Home tab: pregnancy week overview, health summary, and quick actions.
//

import SwiftUI

struct HomeView: View {

    @Environment(AppState.self) private var appState
    @State private var vm = HomeViewModel()

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color.preggoSurface.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        WeekHeroCard(
                            profile: appState.userProfile,
                            weekInfo: vm.weekInfo
                        )
                        QuickHealthCard(appState: appState)
                        WeekInfoCard(weekInfo: vm.weekInfo)
                        Color.clear.frame(height: 20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.preggoNavy, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 1) {
                        Text("PREGGO")
                            .font(.system(size: 18, weight: .bold))
                            .kerning(4)
                            .foregroundStyle(.white)
                        Text("Maternal Intelligence")
                            .font(.preggoCaption)
                            .kerning(1)
                            .foregroundStyle(Color.white.opacity(0.6))
                    }
                }
            }
        }
        .task { vm.refresh(profile: appState.userProfile) }
        .onChange(of: appState.userProfile?.currentGestationalWeek) { _, _ in
            vm.refresh(profile: appState.userProfile)
        }
    }
}

// MARK: - Week Hero Card

private struct WeekHeroCard: View {
    let profile: UserProfile?
    let weekInfo: WeekInfo

    private var week: Int { profile?.currentGestationalWeek ?? 12 }
    private var progress: Double { Double(week) / 40.0 }
    private var trimester: String {
        switch week {
        case 1...12: return "First Trimester"
        case 13...27: return "Second Trimester"
        default: return "Third Trimester"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Week \(week)")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.preggoNavy)
                    Text(trimester)
                        .font(.preggoCaption)
                        .foregroundStyle(Color.preggoMuted)
                        .textCase(.uppercase)
                        .kerning(1.5)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(weekInfo.babySize)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.preggoRose)
                    Text("size of a")
                        .font(.preggoCaption)
                        .foregroundStyle(Color.preggoMuted)
                    Text(weekInfo.babyLength)
                        .font(.preggoCaption)
                        .foregroundStyle(Color.preggoMuted)
                }
            }

            // Progress bar
            VStack(alignment: .leading, spacing: 6) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.preggoNavy.opacity(0.08))
                            .frame(height: 8)
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: [Color.preggoRose.opacity(0.7), Color.preggoRose],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * min(progress, 1.0), height: 8)
                    }
                }
                .frame(height: 8)

                HStack {
                    Text("Week 1")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.preggoMuted)
                    Spacer()
                    Text("\(week) of 40 weeks")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color.preggoRose)
                    Spacer()
                    Text("Week 40")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.preggoMuted)
                }
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color.preggoRose.opacity(0.06), Color.preggoSurface],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.preggoNavy.opacity(0.08), radius: 12, x: 0, y: 4)
    }
}

// MARK: - Quick Health Card

private struct QuickHealthCard: View {
    let appState: AppState

    private var riskColor: Color {
        switch appState.lastAnalysis?.riskLevel {
        case .low:      return .preggoSuccess
        case .moderate: return .preggoWarning
        case .high:     return Color(hex: "#E05252")
        case .critical: return Color(hex: "#C0392B")
        case nil:       return .preggoMuted
        }
    }

    private var riskIcon: String {
        switch appState.lastAnalysis?.riskLevel {
        case .low:      return "checkmark.shield.fill"
        case .moderate: return "exclamationmark.shield.fill"
        case .high:     return "xmark.shield.fill"
        case .critical: return "exclamationmark.triangle.fill"
        case nil:       return "shield.slash.fill"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Label("AI Health Report", systemImage: "waveform.and.magnifyingglass")
                    .font(.preggoHeadline)
                    .foregroundStyle(Color.preggoNavy)
                Spacer()
                if let date = appState.lastAnalysisDate {
                    Text(date.formatted(date: .abbreviated, time: .shortened))
                        .font(.preggoCaption)
                        .foregroundStyle(Color.preggoMuted)
                }
            }

            Divider().background(Color.preggoNavy.opacity(0.08))

            if let analysis = appState.lastAnalysis {
                // Risk level pill — prominent
                HStack(spacing: 10) {
                    Image(systemName: riskIcon)
                        .font(.system(size: 28))
                        .foregroundStyle(riskColor)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Risk Level")
                            .font(.preggoCaption)
                            .foregroundStyle(Color.preggoMuted)
                        Text(analysis.riskLevel.rawValue.uppercased())
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(riskColor)
                    }

                    Spacer()

                    // Colored risk badge
                    Text(analysis.riskLevel.rawValue.capitalized)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(riskColor)
                        .clipShape(Capsule())
                }

                // Personalized message — warm, directly to the mother
                Text(analysis.personalizedMessage)
                    .font(.preggoBody)
                    .foregroundStyle(Color.preggoNavy.opacity(0.85))
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)

                Divider().background(Color.preggoNavy.opacity(0.06))

                // Data sources row — transparency about what powered this
                AnalysisDataSourcesRow(
                    documentCount: appState.lastAnalysisDocumentCount
                )

            } else {
                HStack(spacing: 14) {
                    Image(systemName: "waveform.and.magnifyingglass")
                        .font(.system(size: 32))
                        .foregroundStyle(Color.preggoRose.opacity(0.35))
                    VStack(alignment: .leading, spacing: 4) {
                        Text("No analysis yet")
                            .font(.preggoHeadline)
                            .foregroundStyle(Color.preggoNavy.opacity(0.6))
                        Text("Go to the Health tab to run your first AI assessment")
                            .font(.preggoCaption)
                            .foregroundStyle(Color.preggoMuted)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 4)
            }
        }
        .padding(20)
        .cardStyle()
    }
}

// MARK: - Analysis Data Sources Row

/// Shows the user exactly what data powered this AI analysis — full transparency.
struct AnalysisDataSourcesRow: View {
    let documentCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ANALYZED FROM")
                .font(.system(size: 10, weight: .semibold))
                .kerning(1.5)
                .foregroundStyle(Color.preggoMuted)

            HStack(spacing: 8) {
                DataSourcePill(icon: "waveform.path.ecg", label: "Bio-markers", color: Color.preggoRose)
                DataSourcePill(icon: "person.fill", label: "Profile", color: Color(hex: "#6C7FD8"))
                if documentCount > 0 {
                    DataSourcePill(
                        icon: "doc.text.fill",
                        label: "\(documentCount) doc\(documentCount == 1 ? "" : "s")",
                        color: Color.preggoSuccess
                    )
                }
            }
        }
    }
}

private struct DataSourcePill: View {
    let icon: String
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.preggoNavy.opacity(0.8))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(color.opacity(0.1))
        .clipShape(Capsule())
    }
}

// MARK: - Week Info Card

private struct WeekInfoCard: View {
    let weekInfo: WeekInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Week \(weekInfo.week) Highlights", systemImage: "sparkles")
                .font(.preggoHeadline)
                .foregroundStyle(Color.preggoNavy)

            Divider().background(Color.preggoNavy.opacity(0.08))

            VStack(alignment: .leading, spacing: 12) {
                InfoRow(icon: "star.fill", color: Color.preggoRose, label: "Milestone", text: weekInfo.milestone)
                InfoRow(icon: "lightbulb.fill", color: Color(hex: "#F5A623"), label: "This week's tip", text: weekInfo.tip)
            }
        }
        .padding(20)
        .cardStyle()
    }
}

private struct InfoRow: View {
    let icon: String
    let color: Color
    let label: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(color)
                .frame(width: 20)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 2) {
                Text(label.uppercased())
                    .font(.system(size: 10, weight: .semibold))
                    .kerning(1.2)
                    .foregroundStyle(Color.preggoMuted)
                Text(text)
                    .font(.preggoBody)
                    .foregroundStyle(Color.preggoNavy.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
