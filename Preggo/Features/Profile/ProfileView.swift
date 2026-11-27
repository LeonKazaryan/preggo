//
//  ProfileView.swift
//  Preggo
//
//  Profile tab: pregnancy details, personal info, app settings, about.
//

import SwiftUI

struct ProfileView: View {

    @Environment(AppState.self) private var appState
    @Environment(DocumentStore.self) private var documentStore
    @State private var vm = ProfileViewModel()
    @State private var showResetConfirm = false
    @State private var hasEdits = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.preggoSurface.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        profileHeaderCard
                        pregnancyDetailsSection
                        personalInfoSection
                        appSettingsSection
                        aboutSection
                        Color.clear.frame(height: 32)
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
                        Text("PROFILE")
                            .font(.system(size: 18, weight: .bold))
                            .kerning(4)
                            .foregroundStyle(.white)
                        Text("Pregnancy Details")
                            .font(.preggoCaption)
                            .kerning(1)
                            .foregroundStyle(Color.white.opacity(0.6))
                    }
                }
                if hasEdits {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            vm.saveChanges()
                            hasEdits = false
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.preggoRose)
                    }
                }
            }
            .onAppear {
                vm.load(from: appState)
            }
            .alert("Reset Onboarding?", isPresented: $showResetConfirm) {
                Button("Reset", role: .destructive) { vm.resetOnboarding() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will clear your profile and show the onboarding screens again.")
            }
        }
    }

    // MARK: - Profile Header

    private var profileHeaderCard: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.preggoRose.opacity(0.15))
                    .frame(width: 64, height: 64)
                Text("W\(vm.gestationalWeek)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.preggoRose)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Week \(vm.gestationalWeek)")
                    .font(.preggoHeadline)
                    .foregroundStyle(Color.preggoNavy)
                Text(trimesterLabel(for: vm.gestationalWeek))
                    .font(.preggoCaption)
                    .foregroundStyle(Color.preggoMuted)
                Text("BMI \(String(format: "%.1f", vm.bmi))")
                    .font(.preggoCaption)
                    .foregroundStyle(Color.preggoMuted)
            }
            Spacer()
        }
        .padding(20)
        .cardStyle()
    }

    // MARK: - Pregnancy Details

    private var pregnancyDetailsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: "Pregnancy Details", icon: "heart.fill")

            VStack(spacing: 0) {
                ProfileStepper(
                    label: "Current Week",
                    value: $vm.gestationalWeek,
                    range: 1...42,
                    unit: "weeks"
                ) { hasEdits = true }

                Divider().padding(.leading, 56)

                // Risk Factors
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 18))
                            .foregroundStyle(Color.preggoRose)
                            .frame(width: 32)
                        Text("Risk Factors")
                            .font(.preggoBody)
                            .foregroundStyle(Color.preggoNavy)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        ForEach(RiskFactor.allCases) { factor in
                            let isSelected = vm.selectedRiskFactors.contains(factor)
                            Button {
                                if isSelected {
                                    vm.selectedRiskFactors.remove(factor)
                                } else {
                                    vm.selectedRiskFactors.insert(factor)
                                }
                                hasEdits = true
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: factor.icon)
                                        .font(.system(size: 12))
                                        .foregroundStyle(isSelected ? .white : Color.preggoRose)
                                    Text(factor.displayName)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundStyle(isSelected ? .white : Color.preggoNavy)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                    Spacer(minLength: 0)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(isSelected ? Color.preggoRose : Color.preggoNavy.opacity(0.05))
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            }
                            .buttonStyle(.plain)
                            .animation(.easeInOut(duration: 0.15), value: isSelected)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
            .background(Color.preggoSurface)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Color.preggoNavy.opacity(0.08), radius: 12, x: 0, y: 4)
        }
    }

    // MARK: - Personal Info

    private var personalInfoSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: "Personal Info", icon: "person.fill")

            VStack(spacing: 0) {
                ProfileStepper(label: "Age", value: $vm.age, range: 14...55, unit: "years") { hasEdits = true }
                Divider().padding(.leading, 56)
                ProfileStepperDouble(label: "Weight", value: $vm.weightKg, range: 35...200, step: 0.5, unit: "kg") { hasEdits = true }
                Divider().padding(.leading, 56)
                ProfileStepperDouble(label: "Height", value: $vm.heightCm, range: 120...220, step: 1, unit: "cm") { hasEdits = true }
            }
            .background(Color.preggoSurface)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Color.preggoNavy.opacity(0.08), radius: 12, x: 0, y: 4)
        }
    }

    // MARK: - App Settings

    private var appSettingsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: "App Settings", icon: "gearshape.fill")

            VStack(spacing: 0) {
                // Demo mode row
                HStack(spacing: 16) {
                    Image(systemName: "flask.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.preggoWarning)
                        .frame(width: 32)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Demo Mode")
                            .font(.preggoBody)
                            .foregroundStyle(Color.preggoNavy)
                        Text("Use synthetic health data")
                            .font(.preggoCaption)
                            .foregroundStyle(Color.preggoMuted)
                    }
                    Spacer()
                    Toggle("", isOn: Binding(
                        get: { appState.isDemoMode },
                        set: { appState.isDemoMode = $0 }
                    ))
                    .tint(Color.preggoWarning)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)

                Divider().padding(.leading, 56)

                // Documents count
                HStack(spacing: 16) {
                    Image(systemName: "doc.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.preggoRose)
                        .frame(width: 32)
                    Text("Scanned Documents")
                        .font(.preggoBody)
                        .foregroundStyle(Color.preggoNavy)
                    Spacer()
                    Text("\(documentStore.documents.count)")
                        .font(.preggoBody)
                        .foregroundStyle(Color.preggoMuted)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)

                Divider().padding(.leading, 56)

                // Reset onboarding
                Button {
                    showResetConfirm = true
                } label: {
                    HStack(spacing: 16) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 18))
                            .foregroundStyle(Color(hex: "#E05252"))
                            .frame(width: 32)
                        Text("Reset Onboarding")
                            .font(.preggoBody)
                            .foregroundStyle(Color(hex: "#E05252"))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.preggoMuted)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }
            }
            .background(Color.preggoSurface)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Color.preggoNavy.opacity(0.08), radius: 12, x: 0, y: 4)
        }
    }

    // MARK: - About

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: "About", icon: "info.circle.fill")

            VStack(spacing: 0) {
                AboutRow(label: "Version", value: "1.0.0")
                Divider().padding(.leading, 56)
                AboutRow(label: "AI Model", value: "Grok 4.20")
                Divider().padding(.leading, 56)
                AboutRow(label: "Team", value: "Kazaryan · Ashykhatov · Dautbek")
            }
            .background(Color.preggoSurface)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Color.preggoNavy.opacity(0.08), radius: 12, x: 0, y: 4)

            Text("Preggo is not a medical device. Always consult your healthcare provider for medical decisions.")
                .font(.preggoCaption)
                .foregroundStyle(Color.preggoMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
                .padding(.top, 12)
        }
    }

    private func trimesterLabel(for week: Int) -> String {
        switch week {
        case 1...12: return "First Trimester"
        case 13...27: return "Second Trimester"
        default: return "Third Trimester"
        }
    }
}

// MARK: - Section Header

private struct SectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundStyle(Color.preggoMuted)
            Text(title.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .kerning(1.5)
                .foregroundStyle(Color.preggoMuted)
        }
        .padding(.horizontal, 4)
        .padding(.bottom, 8)
        .padding(.top, 4)
    }
}

// MARK: - Profile Stepper (Int)

private struct ProfileStepper: View {
    let label: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let unit: String
    let onChange: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "calendar")
                .font(.system(size: 18))
                .foregroundStyle(Color.preggoRose)
                .frame(width: 32)
            Text(label)
                .font(.preggoBody)
                .foregroundStyle(Color.preggoNavy)
            Spacer()
            HStack(spacing: 8) {
                Button {
                    if value > range.lowerBound { value -= 1; onChange() }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Color.preggoMuted.opacity(0.5))
                }
                Text("\(value)")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.preggoNavy)
                    .frame(minWidth: 36)
                Button {
                    if value < range.upperBound { value += 1; onChange() }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Color.preggoRose)
                }
            }
            Text(unit)
                .font(.preggoCaption)
                .foregroundStyle(Color.preggoMuted)
                .frame(width: 36)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

// MARK: - Profile Stepper (Double)

private struct ProfileStepperDouble: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let unit: String
    let onChange: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "scalemass")
                .font(.system(size: 18))
                .foregroundStyle(Color.preggoRose)
                .frame(width: 32)
            Text(label)
                .font(.preggoBody)
                .foregroundStyle(Color.preggoNavy)
            Spacer()
            HStack(spacing: 8) {
                Button {
                    if value - step >= range.lowerBound { value -= step; onChange() }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Color.preggoMuted.opacity(0.5))
                }
                Text(step < 1 ? String(format: "%.1f", value) : String(format: "%.0f", value))
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.preggoNavy)
                    .frame(minWidth: 42)
                Button {
                    if value + step <= range.upperBound { value += step; onChange() }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Color.preggoRose)
                }
            }
            Text(unit)
                .font(.preggoCaption)
                .foregroundStyle(Color.preggoMuted)
                .frame(width: 36)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

// MARK: - About Row

private struct AboutRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "circle.fill")
                .font(.system(size: 6))
                .foregroundStyle(Color.preggoRose)
                .frame(width: 32)
            Text(label)
                .font(.preggoBody)
                .foregroundStyle(Color.preggoNavy)
            Spacer()
            Text(value)
                .font(.preggoCaption)
                .foregroundStyle(Color.preggoMuted)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}
