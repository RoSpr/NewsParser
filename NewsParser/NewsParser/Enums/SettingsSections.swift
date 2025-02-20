//
//  SettingsSctions.swift
//  NewsParser
//
//  Created by Rodion on 01.02.2025.
//

enum SettingsSections: Int, CaseIterable {
    case updates = 0, languages, initialSources, newsSources, cache
    
    func getTitle() -> String {
        switch self {
        case .updates:
            return "Updates".localized()
        case .languages:
            return "Languages".localized()
        case .initialSources:
            return "News_sources".localized()
        case .newsSources:
            return ""
        case .cache:
            return "Cache".localized()
        }
    }
    
    func getCellText() -> String? {
        switch self {
        case .updates:
            return "Refresh_frequency".localized()
        case .languages:
            return "Languages".localized()
        case .initialSources:
            return "Add_sources".localized()
        case .newsSources:
            return nil
        case .cache:
            return "Clear_cache".localized()
        }
    }
    
    func getNumberOfRows() -> Int {
        return 1
    }
}
