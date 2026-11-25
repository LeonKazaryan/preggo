//
//  HomeViewModel.swift
//  Preggo
//
//  Powers the Home tab with pregnancy week data and quick health summary.
//

import Foundation
import Observation

@Observable
@MainActor
final class HomeViewModel {

    var weekInfo: WeekInfo = PregnancyWeekData.info(for: 12)

    func refresh(profile: UserProfile?) {
        let week = profile?.currentGestationalWeek ?? 12
        weekInfo = PregnancyWeekData.info(for: week)
    }
}
