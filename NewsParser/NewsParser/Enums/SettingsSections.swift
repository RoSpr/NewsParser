//
//  SettingsSctions.swift
//  NewsParser
//
//  Created by Rodion on 01.02.2025.
//

enum SettingsSections: Int, CaseIterable {
    case updates = 0, languages, initialSources, newsSources, cache, version
    
    func getTitle() -> String {
        switch self {
        case .updates:
            return "Updates".localized()
        case .languages:
            return "Languages".localized()
        case .initialSources:
            return "News_sources".localized()
        case .cache:
            return "Cache".localized()
        default: return ""
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
        case .cache:
            return "Cache".localized()
        case .version:
            return "VersionNumber".localized()
        default: return nil
        }
    }
    
    func getNumberOfRows() -> Int {
        return 1
    }
}
