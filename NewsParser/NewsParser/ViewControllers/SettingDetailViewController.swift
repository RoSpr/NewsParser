//
//  SettingDetailViewController.swift
//  NewsParser
//
//  Created by Rodion on 20.02.2025.
//

import UIKit
import Combine

final class SettingDetailViewController: UITableViewController {
    private var cancellables = Set<AnyCancellable>()
    
    var viewModel: SettingDetailViewModel?
    
    init(viewModel: SettingDetailViewModel) {
        self.viewModel = viewModel
        
        super.init(style: .insetGrouped)
        
        tableView.allowsMultipleSelection = false
        tableView.overrideUserInterfaceStyle = .light
        
        self.navigationItem.title = viewModel.title
        
        bindViewModel()
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
        cell.detailTextLabel?.text = viewModel?.detailTextForRow(at: indexPath)
        cell.selectionStyle = (viewModel?.isRowSelectable(at: indexPath) ?? false) == true ? .default : .none
        
        if let color = viewModel?.colorForText(at: indexPath) {
            cell.textLabel?.textColor = color
        }
        
        if let selectedCellIndex = viewModel?.previouslySelectedRowIndex, selectedCellIndex == indexPath {
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard (viewModel?.isRowSelectable(at: indexPath) ?? false) else { return }
        
        if let selectedCellIndex = viewModel?.previouslySelectedRowIndex {
            let selectedCell = tableView.cellForRow(at: selectedCellIndex)
            selectedCell?.accessoryType = .none
        }
        
        viewModel?.choseRow(at: indexPath)
        
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = viewModel?.accessoryTypeForRow(at: indexPath) ?? .none
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func bindViewModel() {
        guard let viewModel = viewModel as? RxSettingDetailViewModel else { return }
        viewModel.reloadCellPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] indexPaths in
                guard let self = self else { return }
                self.tableView.reloadRows(at: indexPaths, with: .none)
            }
            .store(in: &cancellables)
    }
}
