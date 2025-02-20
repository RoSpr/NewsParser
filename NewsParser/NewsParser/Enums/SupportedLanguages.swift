//
//  SupportedLanguages.swift
//  NewsParser
//
//  Created by Rodion on 01.02.2025.
//

enum SupportedLanguages: String, CaseIterable {
    case en, ru
    
    func description() -> String {
        switch self {
        case .en:
            return "English".localized()
        case .ru:
            return "Russian".localized()
        }
    }
    
    static func language(at index: Int) -> SupportedLanguages? {
        let allLanguages = SupportedLanguages.allCases
        return allLanguages[index]
    }
    
    static func index(for language: SupportedLanguages) -> Int? {
        let allLanguages = SupportedLanguages.allCases
        return allLanguages.firstIndex(of: language)
    }
}
