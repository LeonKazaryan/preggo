//
//  HealthKitPermissionStepView.swift
//  Preggo
//
//  Onboarding step 5: dedicated HealthKit permission explanation screen.
//

import SwiftUI

struct HealthKitPermissionStepView: View {

    @Bindable var vm: OnboardingViewModel

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 60)

            // Icon
            ZStack {
                Circle()
                    .fill(Color.preggoRose.opacity(0.12))
                    .frame(width: 100, height: 100)
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.preggoRose)
            }

            Spacer().frame(height: 28)

            Text("Health Access")
                .font(.preggoTitle)
                .foregroundStyle(Color.preggoNavy)

            Spacer().frame(height: 16)

            Text("Preggo monitors three key bio-markers from your Apple Watch to detect early risk signals between doctor visits.")
                .font(.preggoBody)
                .foregroundStyle(Color.preggoNavy.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer().frame(height: 32)

            VStack(spacing: 14) {
                PermissionRow(
                    icon: "heart.fill",
                    title: "Heart Rate Variability",
                    description: "HRV changes can signal autonomic stress and pre-eclampsia risk"
                )
                PermissionRow(
                    icon: "heart.circle.fill",
                    title: "Resting Heart Rate",
                    description: "Elevation may indicate cardiovascular or metabolic stress"
                )
                PermissionRow(
                    icon: "lungs.fill",
                    title: "Respiratory Rate",
                    description: "Early sign of pulmonary complications in pregnancy"
                )
            }
            .padding(.horizontal, 24)

            if let err = vm.healthKitError {
                Text(err)
                    .font(.preggoCaption)
                    .foregroundStyle(Color.preggoWarning)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
            }

            Spacer()

            VStack(spacing: 12) {
                Button {
                    Task { await vm.requestHealthKit() }
                } label: {
                    HStack(spacing: 8) {
                        if vm.healthKitGranted {
                            Image(systemName: "checkmark.circle.fill")
                        } else {
                            Image(systemName: "heart.fill")
                        }
                        Text(vm.healthKitGranted ? "Access Granted" : "Allow Health Access")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(vm.healthKitGranted ? Color.preggoSuccess : Color.preggoRose)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .disabled(vm.healthKitGranted)

                Button {
                    vm.next()
                } label: {
                    Text("Skip for now")
                        .font(.preggoBody)
                        .foregroundStyle(Color.preggoMuted)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
            .onChange(of: vm.healthKitGranted) { _, granted in
                if granted {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        vm.next()
                    }
                }
            }
        }
    }
}

private struct PermissionRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundStyle(Color.preggoRose)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.preggoNavy)
                Text(description)
                    .font(.preggoCaption)
                    .foregroundStyle(Color.preggoMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
    }
}
