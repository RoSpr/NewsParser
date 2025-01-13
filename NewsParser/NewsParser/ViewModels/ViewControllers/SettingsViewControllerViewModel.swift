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
    
    var delegate: SettingsViewControllerDelegate? { get set }
    
    var numberOfSections: Int { get }
    func numberOfRowsIn(section: Int) -> Int
    
    func getNewsSourceTitleOrLink(at index: Int) -> String?
    func isSourceVisible(at index: Int) -> Bool
    func toggleNewsSourceVisibility(at index: Int)
}

enum UpdateFrequenciesInMins: Int, CaseIterable {
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

final class SettingsViewControllerViewModelImpl: SettingsViewControllerViewModel {
    var selectedFrequency: UpdateFrequenciesInMins {
        get {
            let rawValue = (DatabaseManager.shared.retrieveValueFromUD(key: .refreshInterval) as? Int) ?? 0
            return UpdateFrequenciesInMins(rawValue: rawValue) ?? .fiveMin
        }
        set {
            DatabaseManager.shared.saveValueToUD(key: .refreshInterval, value: newValue.rawValue)
        }
    }
    
    var newsSources: [NewsSource] = Array(DatabaseManager.shared.fetch(NewsSource.self).sorted(by: { $0.dateAdded < $1.dateAdded }))
    
    var delegate: SettingsViewControllerDelegate?
    
    var numberOfSections: Int {
        return 3
    }
    
    init() {
        addNotificationToken()
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
        
        DatabaseManager.shared.update {
            source.isActive.toggle()
        }
    }
    
    private func addNotificationToken() {
        DatabaseManager.shared.observeChanges(for: NewsSource.self) { [weak self] changes in
            guard let self = self else { return }
            
            switch changes {
            case .initial(_):
                break
            case .update(let allElements, deletions: let deletions, insertions: let insertions, modifications: let modifications):
                self.newsSources = Array(allElements).sorted(by: { $0.dateAdded < $1.dateAdded })
                self.delegate?.reloadSources()
            case .error(let error):
                print("Error observing NewsSourcee changes: \(error)")
            }
        }
    }
}
