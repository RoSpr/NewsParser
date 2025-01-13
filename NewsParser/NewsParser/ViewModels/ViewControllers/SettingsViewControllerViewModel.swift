//
//  SettingsViewControllerViewModel.swift
//  NewsParser
//
//  Created by Rodion on 10.01.2025.
//

import Foundation

protocol SettingsViewControllerViewModel {
    var selectedFrequency: UpdateFrequencies { get set }
    var newsSources: [NewsSource] { get }
    
    var delegate: SettingsViewControllerDelegate? { get set }
    
    var numberOfSections: Int { get }
    func numberOfRowsIn(section: Int) -> Int
    
    func getNewsSourceTitleOrLink(at index: Int) -> String?
    func isSourceVisible(at index: Int) -> Bool
    func toggleNewsSourceVisibility(at index: Int)
}

final class SettingsViewControllerViewModelImpl: SettingsViewControllerViewModel {
    var selectedFrequency: UpdateFrequencies {
        get {
            let rawValue = (DatabaseManager.shared.retrieveValueFromUD(key: .refreshInterval) as? Int) ?? 0
            return UpdateFrequencies(rawValue: rawValue) ?? .fiveMin
        }
        set {
            DatabaseManager.shared.saveValueToUD(key: .refreshInterval, value: newValue.rawValue)
            NotificationCenter.default.post(name: .didChangeRefreshInterval, object: nil)
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
