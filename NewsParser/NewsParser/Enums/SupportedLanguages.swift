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
}
