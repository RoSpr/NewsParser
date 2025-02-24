//
//  SettingDetailViewModel.swift
//  NewsParser
//
//  Created by Rodion on 20.02.2025.
//

import UIKit

protocol SettingDetailViewModel {
    var title: String? { get }
    var numberOfSections: Int { get }
    var previouslySelectedRowIndex: IndexPath? { get }
    
    func numberOfRows(in section: Int) -> Int
    func textForRow(at index: IndexPath) -> String
    func colorForText(at index: IndexPath) -> UIColor?
    func detailTextForRow(at index: IndexPath) -> String
    func choseRow(at index: IndexPath)
    
    func isRowSelectable(at index: IndexPath) -> Bool
    func accessoryTypeForRow(at index: IndexPath) -> UITableViewCell.AccessoryType
}
