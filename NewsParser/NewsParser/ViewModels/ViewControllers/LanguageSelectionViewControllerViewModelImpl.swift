//
//  LanguageSelectionViewControllerViewModel.swift
//  NewsParser
//
//  Created by Rodion on 20.02.2025.
//

import UIKit

final class LanguageSelectionViewControllerViewModelImpl: SettingDetailViewModel {
    var title: String? = "LanguageSelection".localized()
    var numberOfSections: Int = 1
    var previouslySelectedRowIndex: IndexPath?
    
    init() {
        guard let rawLang = DatabaseManager.shared.retrieveValueFromUD(key: .selectedLanguage) as? String,
              let language = SupportedLanguages(rawValue: rawLang),
              let row = SupportedLanguages.index(for: language) else {
            previouslySelectedRowIndex = nil
            return
        }
        previouslySelectedRowIndex = IndexPath(row: row, section: 0)
    }
    
    func numberOfRows(in section: Int) -> Int {
        guard section <= numberOfSections - 1 else { return 0 }
        return SupportedLanguages.allCases.count
    }
    
    func textForRow(at index: IndexPath) -> String {
        SupportedLanguages.language(at: index.row)?.description() ?? ""
    }
    
    func colorForText(at index: IndexPath) -> UIColor? {
        return nil
    }
    
    func detailTextForRow(at index: IndexPath) -> String {
        return ""
    }
    
    func choseRow(at index: IndexPath) {
        guard let language = SupportedLanguages.language(at: index.row) else { return }
        
        Bundle.setLanguage(language.rawValue)
        previouslySelectedRowIndex = index
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let sceneDelegate = scene.delegate as? SceneDelegate {
            sceneDelegate.recreateRootControllers()
        }
    }
    
    func isRowSelectable(at index: IndexPath) -> Bool {
        return true
    }
    
    func accessoryTypeForRow(at index: IndexPath) -> UITableViewCell.AccessoryType {
        return .checkmark
    }
}
