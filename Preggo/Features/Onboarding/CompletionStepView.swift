//
//  CompletionStepView.swift
//  Preggo
//
//  Final onboarding screen — animated completion and launch.
//

import SwiftUI

struct CompletionStepView: View {

    let onComplete: () -> Void

    @State private var showCheck = false
    @State private var showText = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Animated checkmark
            ZStack {
                Circle()
                    .fill(Color.preggoRose.opacity(0.1))
                    .frame(width: 120, height: 120)
                    .scaleEffect(showCheck ? 1 : 0.5)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: showCheck)

                Circle()
                    .fill(Color.preggoRose.opacity(0.2))
                    .frame(width: 90, height: 90)
                    .scaleEffect(showCheck ? 1 : 0.3)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1), value: showCheck)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(Color.preggoRose)
                    .scaleEffect(showCheck ? 1 : 0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.2), value: showCheck)
            }

            Spacer().frame(height: 36)

            VStack(spacing: 8) {
                Text("You're all set!")
                    .font(.preggoTitle)
                    .foregroundStyle(Color.preggoNavy)

                Text("Preggo is ready to help you stay\nconfident and informed throughout your pregnancy.")
                    .font(.preggoBody)
                    .foregroundStyle(Color.preggoMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .opacity(showText ? 1 : 0)
            .offset(y: showText ? 0 : 20)
            .animation(.easeOut(duration: 0.4).delay(0.4), value: showText)

            Spacer()

            Button(action: onComplete) {
                Text("Start Monitoring")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.preggoRose)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .shadow(color: Color.preggoRose.opacity(0.3), radius: 12, y: 6)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
            .opacity(showText ? 1 : 0)
            .animation(.easeOut(duration: 0.3).delay(0.7), value: showText)
        }
        .onAppear {
            showCheck = true
            showText = true
        }
    }
}
