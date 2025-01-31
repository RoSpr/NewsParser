//
//  UpdateFrequencies.swift
//  NewsParser
//
//  Created by Rodion on 13.01.2025.
//

import Foundation

enum UpdateFrequencies: Int, CaseIterable {
    case fiveMin = 0, fifteenMin, halfHour, hour, sixHours, twelveHours, day
    
    func getIntValue() -> Int {
        switch self {
        case .fiveMin:
            return 5
        case .fifteenMin:
            return 15
        case .halfHour:
            return 30
        case .hour:
            return 60
        case .sixHours:
            return 360
        case .twelveHours:
            return 720
        case .day:
            return 1440
        }
    }
    
    func getTextDescription() -> String {
        switch self {
        case .fiveMin:
            return "Minutes".localized("5")
        case .fifteenMin:
            return "Minutes".localized("15")
        case .halfHour:
            return "Minutes".localized("30")
        case .hour:
            return "Hour".localized()
        case .sixHours:
            return "Hours".localized("6")
        case .twelveHours:
            return "Hours".localized("12")
        case .day:
            return "Day".localized()
        }
    }
}
