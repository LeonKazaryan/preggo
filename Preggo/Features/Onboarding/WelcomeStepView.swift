//
//  WelcomeStepView.swift
//  Preggo
//
//  First onboarding screen — hero branding and value proposition.
//

import SwiftUI

struct WelcomeStepView: View {

    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Logo
            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color.preggoRose.opacity(0.1))
                    .frame(width: 120, height: 120)

                Image("preggo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            }
            .shadow(color: Color.preggoRose.opacity(0.3), radius: 20, y: 10)

            Spacer().frame(height: 36)

            // Title
            Text("PREGGO")
                .font(.system(size: 36, weight: .bold))
                .kerning(6)
                .foregroundStyle(Color.preggoNavy)

            Text("Maternal Intelligence")
                .font(.preggoBody)
                .kerning(2)
                .foregroundStyle(Color.preggoMuted)
                .padding(.top, 4)

            Spacer().frame(height: 40)

            // Value prop
            VStack(spacing: 16) {
                FeatureRow(icon: "waveform.path.ecg", text: "Continuous health monitoring")
                FeatureRow(icon: "brain.head.profile", text: "AI-powered risk detection")
                FeatureRow(icon: "doc.text.magnifyingglass", text: "Smart document scanning")
                FeatureRow(icon: "stethoscope", text: "Doctor-ready reports")
            }
            .padding(.horizontal, 40)

            Spacer()

            // CTA
            Button(action: onContinue) {
                Text("Get Started")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.preggoRose)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)

            Text("Know earlier, worry less.")
                .font(.preggoCaption)
                .foregroundStyle(Color.preggoMuted)
                .padding(.bottom, 32)
        }
    }
}

private struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(Color.preggoRose)
                .frame(width: 32)
            Text(text)
                .font(.preggoBody)
                .foregroundStyle(Color.preggoNavy)
            Spacer()
        }
    }
}
