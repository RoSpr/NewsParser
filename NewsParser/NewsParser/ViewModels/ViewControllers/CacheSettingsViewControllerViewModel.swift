//
//  CacheSettingsViewControllerViewModel.swift
//  NewsParser
//
//  Created by Rodion on 22.02.2025.
//

import UIKit

final class CacheSettingsViewControllerViewModel: SettingDetailViewModel {
    var title: String? = "Cache".localized()
    
    var numberOfSections: Int = CacheSections.allCases.count
    
    var previouslySelectedRowIndex: IndexPath? = nil
    
    func numberOfRows(in section: Int) -> Int {
        return 1
    }
    
    func textForRow(at index: IndexPath) -> String {
        guard let section = CacheSections(rawValue: index.section) else { return "" }
        return section.getCellText()
    }
    
    func colorForText(at index: IndexPath) -> UIColor? {
        guard index.section == 1 else { return nil }
        return .red
    }
    
    func detailTextForRow(at index: IndexPath) -> String {
        guard index.section == 0 else { return "" }
        let size = ImageCacheManager.shared.getStoredImagesSize()
        return Utils.convertBytesToString(size)
    }
    
    func choseRow(at index: IndexPath) {
        switch index.section {
        case 1:
            Utils.makePopUp(parent: nil, title: nil, message: "Clear_cache_question".localized(), actionTitle: "Delete".localized(), actionStyle: .destructive, cancelTitle: "Cancel".localized(), actionHandler: { [weak self] in
                self?.clearCache()
            })
        default: break
        }
    }
    
    func isRowSelectable(at index: IndexPath) -> Bool {
        guard index.section == 1 else { return false }
        return true
    }
    
    func accessoryTypeForRow(at index: IndexPath) -> UITableViewCell.AccessoryType {
        return .none
    }
    
    private func clearCache() {
        DatabaseManager.shared.deleteAll()
        ImageCacheManager.shared.deleteImageCache()
    }
}
