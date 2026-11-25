//
//  RiskFactorsStepView.swift
//  Preggo
//
//  Onboarding step 4: optional risk factor selection.
//

import SwiftUI

struct RiskFactorsStepView: View {

    @Bindable var vm: OnboardingViewModel

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 60)

            Text("Any risk factors?")
                .font(.preggoTitle)
                .foregroundStyle(Color.preggoNavy)
                .multilineTextAlignment(.center)

            Text("This helps our AI give you more precise insights.\nYou can skip this or update it later.")
                .font(.preggoBody)
                .foregroundStyle(Color.preggoMuted)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
                .padding(.horizontal, 24)

            Spacer().frame(height: 32)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(RiskFactor.allCases) { factor in
                    RiskFactorChip(
                        factor: factor,
                        isSelected: vm.selectedRiskFactors.contains(factor)
                    ) {
                        if vm.selectedRiskFactors.contains(factor) {
                            vm.selectedRiskFactors.remove(factor)
                        } else {
                            vm.selectedRiskFactors.insert(factor)
                        }
                    }
                }
            }
            .padding(.horizontal, 24)

            if !vm.selectedRiskFactors.isEmpty {
                Text("\(vm.selectedRiskFactors.count) selected")
                    .font(.preggoCaption)
                    .foregroundStyle(Color.preggoRose)
                    .padding(.top, 12)
            }

            Spacer()

            OnboardingNavigationButtons(
                onBack: { vm.back() },
                onNext: { vm.next() },
                showBack: true,
                canProceed: true,
                nextLabel: vm.selectedRiskFactors.isEmpty ? "Skip" : "Continue"
            )
        }
    }
}

private struct RiskFactorChip: View {
    let factor: RiskFactor
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: factor.icon)
                    .font(.system(size: 14))
                    .foregroundStyle(isSelected ? .white : Color.preggoRose)
                Text(factor.displayName)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(isSelected ? .white : Color.preggoNavy)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .background(isSelected ? Color.preggoRose : Color.preggoNavy.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(isSelected ? Color.preggoRose : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}
