//
//  SettingsViewControllerViewModel.swift
//  NewsParser
//
//  Created by Rodion on 24.02.2025.
//

protocol SettingsViewControllerViewModel {
    var selectedFrequency: UpdateFrequencies { get set }
    var newsSources: [NewsSource] { get }
    
    var selectedLanguage: SupportedLanguages { get }
    
    var version: String { get }
    
    var delegate: SettingsViewControllerDelegate? { get set }
    
    var numberOfSections: Int { get }
    func numberOfRowsIn(section: Int) -> Int
    
    func getSectionType(_ section: Int) -> SettingsSections?
    
    func getTitleForHeader(in section: Int) -> String?
    
    func getNewsSourceTitleOrLink(at index: Int) -> String?
    func isSourceVisible(at index: Int) -> Bool
    func toggleNewsSourceVisibility(at index: Int)
    
    func deleteSource(at index: Int)
}
