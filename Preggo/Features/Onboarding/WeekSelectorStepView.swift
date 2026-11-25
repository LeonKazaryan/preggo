//
//  WeekSelectorStepView.swift
//  Preggo
//
//  Onboarding step 2: select current pregnancy week.
//

import SwiftUI

struct WeekSelectorStepView: View {

    @Bindable var vm: OnboardingViewModel

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 60)

            Text("What week are\nyou in?")
                .font(.preggoTitle)
                .foregroundStyle(Color.preggoNavy)
                .multilineTextAlignment(.center)

            Text("This helps us tailor insights to your stage")
                .font(.preggoBody)
                .foregroundStyle(Color.preggoMuted)
                .padding(.top, 8)

            Spacer().frame(height: 40)

            // Week picker
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.preggoRose.opacity(0.08))
                    .frame(height: 48)
                    .padding(.horizontal, 80)

                Picker("Week", selection: $vm.gestationalWeek) {
                    ForEach(1...42, id: \.self) { week in
                        Text("Week \(week)")
                            .tag(week)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 160)
            }

            // Baby size hint
            let weekInfo = PregnancyWeekData.info(for: vm.gestationalWeek)
            VStack(spacing: 8) {
                Text("Your baby is the size of")
                    .font(.preggoCaption)
                    .foregroundStyle(Color.preggoMuted)
                Text(weekInfo.babySize)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Color.preggoRose)
                Text(weekInfo.babyLength)
                    .font(.preggoCaption)
                    .foregroundStyle(Color.preggoMuted)
            }
            .padding(.top, 20)

            Spacer()

            // Navigation
            OnboardingNavigationButtons(
                onBack: { vm.back() },
                onNext: { vm.next() },
                showBack: true,
                canProceed: vm.canProceed
            )
        }
    }
}
