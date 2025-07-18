//
//  SettingsViewControllerViewModel.swift
//  NewsParser
//
//  Created by Rodion on 10.01.2025.
//

import Foundation

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
    
    var selectedLanguage: SupportedLanguages {
        let language = DatabaseManager.shared.retrieveValueFromUD(key: .selectedLanguage) as? String ?? "en"
        return SupportedLanguages(rawValue: language) ?? .en
    }
    
    var version: String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0.0"
    }
    
    var delegate: SettingsViewControllerDelegate?
    
    var numberOfSections: Int {
        return SettingsSections.allCases.count
    }
    
    init() {
        addNotificationToken()
    }
    
    func numberOfRowsIn(section: Int) -> Int {
        guard let sectionType = getSectionType(section) else { return 0 }
        
        switch sectionType {
        case .newsSources:
            return newsSources.count
        default:
            return sectionType.getNumberOfRows()
        }
    }
    
    func getSectionType(_ section: Int) -> SettingsSections? {
        return SettingsSections(rawValue: section) ?? nil
    }
    
    func getTitleForHeader(in section: Int) -> String? {
        guard let sectionType = getSectionType(section) else { return nil }
        
        return sectionType.getTitle()
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
    
    func deleteSource(at index: Int) {
        guard index < newsSources.count else { return }
        
        let source = newsSources[index]
        
        DatabaseManager.shared.delete(source)
    }
    
    private func addNotificationToken() {
        DatabaseManager.shared.observeChanges(for: NewsSource.self) { [weak self] changes in
            guard let self = self else { return }
            
            switch changes {
            case .initial(_):
                break
            case .update(let allElements, deletions: _, insertions: _, modifications: _):
                self.newsSources = Array(allElements).sorted(by: { $0.dateAdded < $1.dateAdded })
                self.delegate?.reloadSources()
            case .error(let error):
                print("Error observing NewsSourcee changes: \(error)")
            }
        }
    }
}
