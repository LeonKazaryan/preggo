//
//  MetricsStepView.swift
//  Preggo
//
//  Onboarding step 3: age, weight, height.
//

import SwiftUI

struct MetricsStepView: View {

    @Bindable var vm: OnboardingViewModel

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 60)

            Text("A little about you")
                .font(.preggoTitle)
                .foregroundStyle(Color.preggoNavy)
                .multilineTextAlignment(.center)

            Text("This helps our AI give you personalized insights")
                .font(.preggoBody)
                .foregroundStyle(Color.preggoMuted)
                .padding(.top, 8)

            Spacer().frame(height: 40)

            VStack(spacing: 24) {
                // Age
                MetricField(
                    label: "Age",
                    icon: "calendar",
                    value: $vm.age,
                    unit: "years",
                    range: 14...55
                )

                // Weight
                MetricFieldDouble(
                    label: "Weight",
                    icon: "scalemass",
                    value: $vm.weightKg,
                    unit: "kg",
                    range: 35...200,
                    step: 0.5
                )

                // Height
                MetricFieldDouble(
                    label: "Height",
                    icon: "ruler",
                    value: $vm.heightCm,
                    unit: "cm",
                    range: 120...220,
                    step: 1
                )
            }
            .padding(.horizontal, 24)

            Spacer()

            OnboardingNavigationButtons(
                onBack: { vm.back() },
                onNext: { vm.next() },
                showBack: true,
                canProceed: vm.canProceed
            )
        }
    }
}

// MARK: - Metric Field (Int)

private struct MetricField: View {
    let label: String
    let icon: String
    @Binding var value: Int
    let unit: String
    let range: ClosedRange<Int>

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(Color.preggoRose)
                .frame(width: 32)

            Text(label)
                .font(.preggoBody)
                .foregroundStyle(Color.preggoNavy)

            Spacer()

            HStack(spacing: 8) {
                Button {
                    if value > range.lowerBound { value -= 1 }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(Color.preggoMuted.opacity(0.5))
                }

                Text("\(value)")
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.preggoNavy)
                    .frame(minWidth: 50)

                Button {
                    if value < range.upperBound { value += 1 }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(Color.preggoRose)
                }
            }

            Text(unit)
                .font(.preggoCaption)
                .foregroundStyle(Color.preggoMuted)
                .frame(width: 36)
        }
        .padding(16)
        .background(Color.preggoNavy.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

// MARK: - Metric Field (Double)

private struct MetricFieldDouble: View {
    let label: String
    let icon: String
    @Binding var value: Double
    let unit: String
    let range: ClosedRange<Double>
    let step: Double

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(Color.preggoRose)
                .frame(width: 32)

            Text(label)
                .font(.preggoBody)
                .foregroundStyle(Color.preggoNavy)

            Spacer()

            HStack(spacing: 8) {
                Button {
                    if value - step >= range.lowerBound { value -= step }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(Color.preggoMuted.opacity(0.5))
                }

                Text(step < 1 ? String(format: "%.1f", value) : String(format: "%.0f", value))
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.preggoNavy)
                    .frame(minWidth: 50)

                Button {
                    if value + step <= range.upperBound { value += step }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(Color.preggoRose)
                }
            }

            Text(unit)
                .font(.preggoCaption)
                .foregroundStyle(Color.preggoMuted)
                .frame(width: 36)
        }
        .padding(16)
        .background(Color.preggoNavy.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
