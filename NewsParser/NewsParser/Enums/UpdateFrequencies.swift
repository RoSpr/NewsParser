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
            return "5 минут"
        case .fifteenMin:
            return "15 минут"
        case .halfHour:
            return "30 минут"
        case .hour:
            return "1 час"
        case .sixHours:
            return "6 часов"
        case .twelveHours:
            return "12 часов"
        case .day:
            return "день"
        }
    }
}
