//
//  SettingDetailViewController.swift
//  NewsParser
//
//  Created by Rodion on 20.02.2025.
//

import UIKit

final class SettingDetailViewController: UITableViewController {
    var viewModel: SettingDetailViewModel?
    
    init(viewModel: SettingDetailViewModel) {
        self.viewModel = viewModel
        
        super.init(style: .insetGrouped)
        
        tableView.allowsMultipleSelection = false
        tableView.overrideUserInterfaceStyle = .light
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel?.numberOfSections ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfRows(in: section) ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        cell.overrideUserInterfaceStyle = .light
        cell.textLabel?.text = viewModel?.textForRow(at: indexPath)
        
        if let selectedCellIndex = viewModel?.previouslySelectedRowIndex, selectedCellIndex == indexPath {
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedCellIndex = viewModel?.previouslySelectedRowIndex {
            let selectedCell = tableView.cellForRow(at: selectedCellIndex)
            selectedCell?.accessoryType = .none
        }
        
        viewModel?.choseRow(at: indexPath)
        
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
