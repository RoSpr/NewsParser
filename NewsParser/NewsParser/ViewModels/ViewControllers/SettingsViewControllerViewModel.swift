//
//  SettingsViewControllerViewModel.swift
//  NewsParser
//
//  Created by Rodion on 10.01.2025.
//

import Foundation

protocol SettingsViewControllerViewModel {
    var selectedFrequency: UpdateFrequenciesInMins { get set }
    var newsSources: [NewsSource] { get }
    
    var numberOfSections: Int { get }
    func numberOfRowsIn(section: Int) -> Int
    
    func getNewsSourceTitleOrLink(at index: Int) -> String?
    func isSourceVisible(at index: Int) -> Bool
    func toggleNewsSourceVisibility(at index: Int)
    
    func getDescriptionForFrequency(frequency: UpdateFrequenciesInMins) -> String
}

enum UpdateFrequenciesInMins: Int {
    case fiveMin = 5
    case fifteenMin = 15
    case halfHour = 30
    case hour = 60
    case sixHours = 360
    case twelveHours = 720
    case day = 1440
}

final class SettingsViewControllerViewModelImpl: SettingsViewControllerViewModel {
    var selectedFrequency: UpdateFrequenciesInMins = .fiveMin
    var newsSources: [NewsSource] = Array(DatabaseManager.shared.fetch(NewsSource.self))
    
    var numberOfSections: Int {
        return 3
    }
    
    func numberOfRowsIn(section: Int) -> Int {
        guard section < numberOfSections else { return 0 }
        
        switch section {
        case 0:
            return 1
        case 1:
            return newsSources.count
        case 2:
            return 1
        default:
            return 0
        }
    }
    
    func getNewsSourceTitleOrLink(at index: Int) -> String? {
        guard index < newsSources.count else { return nil }
        
        let source = newsSources[index]
        return source.name ?? source.stringURL
    }
    
    func isSourceVisible(at index: Int) -> Bool {
        guard index < newsSources.count else { return false }
        
        return newsSources[index].isActive
    }
    
    func toggleNewsSourceVisibility(at index: Int) {
        guard index < newsSources.count else { return }
        
        let source = newsSources[index]
        
        let id = newsSources[index].id
        DatabaseManager.shared.update {
//            let realmObject = DatabaseManager.shared.fetch(NewsSource.self, predicate: NSPredicate(format: "id == %@", id)).first
//            realmObject?.isActive.toggle()
            source.isActive.toggle()
        }
    }
    
    func getDescriptionForFrequency(frequency: UpdateFrequenciesInMins) -> String {
        switch frequency {
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
