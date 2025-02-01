//
//  UserDefaultsKeys.swift
//  NewsParser
//
//  Created by Rodion on 13.01.2025.
//

import Foundation

enum UserDefaultsKeys: String, CaseIterable {
    case refreshInterval = "refreshInterval_UDKey"
    case lastRefreshDate = "lastRefreshDate_UDKey"
    case selectedLanguage = "selectedLanguage_UDKey"
}
