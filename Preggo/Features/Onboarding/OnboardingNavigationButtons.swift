//
//  OnboardingNavigationButtons.swift
//  Preggo
//
//  Shared back/next navigation buttons used across onboarding steps.
//

import SwiftUI

struct OnboardingNavigationButtons: View {

    let onBack: () -> Void
    let onNext: () -> Void
    var showBack: Bool = true
    var canProceed: Bool = true
    var nextLabel: String = "Continue"

    var body: some View {
        HStack(spacing: 16) {
            if showBack {
                Button(action: onBack) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundStyle(Color.preggoMuted)
                    .frame(width: 90, height: 52)
                    .background(Color.preggoNavy.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }

            Button(action: onNext) {
                HStack(spacing: 6) {
                    Text(nextLabel)
                        .font(.system(size: 16, weight: .semibold))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(canProceed ? Color.preggoRose : Color.preggoMuted.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .disabled(!canProceed)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 48)
    }
}
