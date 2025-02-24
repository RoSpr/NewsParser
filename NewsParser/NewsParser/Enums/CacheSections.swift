//
//  CacheSections.swift
//  NewsParser
//
//  Created by Rodion on 22.02.2025.
//

enum CacheSections: Int, CaseIterable {
    case totalSize = 0, deletion
    
    func getCellText() -> String {
        switch self {
        case .totalSize:
            return "TotalImageCacheSize".localized()
        case .deletion:
            return "Clear_cache".localized()
        }
    }
}
