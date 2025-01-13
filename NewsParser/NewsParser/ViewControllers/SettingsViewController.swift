//
//  SettingsViewController.swift
//  NewsParser
//
//  Created by Rodion on 22.12.2024.
//

import Foundation
import UIKit

final class SettingsViewController: UIViewController {
    var viewModel: SettingsViewControllerViewModel?
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.overrideUserInterfaceStyle = .light
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        addSubviews()
        setupConstraints()
        setupNavigationBar()
        
        viewModel?.delegate = self
    }
    
    private func addSubviews() {
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Настройки"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialLight)
        appearance.backgroundColor = .clear
        
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.black,
            .font: UIFont.boldSystemFont(ofSize: 32)
        ]
        
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.black,
            .font: UIFont.boldSystemFont(ofSize: 18)
        ]
        
        navigationController?.navigationBar.standardAppearance = appearance
    }
}

//MARK: - UITableViewDataSource
extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return (viewModel?.numberOfSections ?? 0)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfRowsIn(section: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        cell.overrideUserInterfaceStyle = .light
        
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = "Частота обновления"
            cell.detailTextLabel?.text = viewModel?.selectedFrequency.getTextDescription()
            cell.accessoryType = .disclosureIndicator
        case 1:
            let isVisible = viewModel?.isSourceVisible(at: indexPath.row) ?? false
            
            cell.textLabel?.text = viewModel?.getNewsSourceTitleOrLink(at: indexPath.row)
            cell.accessoryType = isVisible ? .checkmark : .none
        case 2:
            cell.textLabel?.text = "Очистить кэш"
            cell.textLabel?.textColor = .red
        default: break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Обновления"
        case 1:
            return "Источники новостей"
        case 2:
            return "Кэш"
        default: return nil
        }
    }
}

//MARK: - UItabelViewDelegate
extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            presentPickerView()
        case 1:
            let cell = tableView.cellForRow(at: indexPath)
            cell?.accessoryType == .checkmark ? (cell?.accessoryType = .none) : (cell?.accessoryType = .checkmark)
            
            viewModel?.toggleNewsSourceVisibility(at: indexPath.row)
        case 2:
            Utils.makePopUp(parent: self, title: nil, message: "Удалить кэш?", actionTitle: "Удалить", actionStyle: .destructive, cancelTitle: "Отмена", actionHandler: {
                DatabaseManager.shared.deleteAll()
            })
        default: break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] (action, view, completionHandler) in
                self?.viewModel?.deleteSource(at: indexPath.row)
                completionHandler(true)
            }
            
            deleteAction.backgroundColor = .red
            
            let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
            configuration.performsFirstActionWithFullSwipe = true
            return configuration
        }
}

//MARK: - UITabBarControllerDelegate
extension SettingsViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let navController = viewController as? UINavigationController,
              navController.tabBarItem.tag == 1,
              self.view.window != nil else { return }
        
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
}

//MARK: - SettingsViewControllerDelegate
protocol SettingsViewControllerDelegate {
    func reloadSources()
}

extension SettingsViewController: SettingsViewControllerDelegate {
    func reloadSources() {
        tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
    }
}

//MARK: - UIPickerViewDelegate
extension SettingsViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return UpdateFrequencies(rawValue: row)?.getTextDescription()
    }
}

//MARK: - UIPickerViewDataSource
extension SettingsViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        UpdateFrequencies.allCases.count
    }
}

//MARK: - Picker View
private extension SettingsViewController {
    func presentPickerView() {
        guard let viewModel = viewModel else { return }
        
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.selectRow(viewModel.selectedFrequency.rawValue, inComponent: 0, animated: false)
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.overrideUserInterfaceStyle = .light
        
        let alertController = UIAlertController(title: "Выберите частоту обновления", message: "\n\n\n\n\n\n\n", preferredStyle: .actionSheet)
        alertController.overrideUserInterfaceStyle = .light
        
        alertController.view.addSubview(picker)
        
        NSLayoutConstraint.activate([
            picker.leftAnchor.constraint(equalTo: alertController.view.leftAnchor, constant: 8),
            picker.topAnchor.constraint(equalTo: alertController.view.topAnchor, constant: 15),
            picker.rightAnchor.constraint(equalTo: alertController.view.rightAnchor, constant: -8),
            picker.bottomAnchor.constraint(equalTo: alertController.view.bottomAnchor, constant: -110)
        ])
        
        alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Выбрать", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            if let selectedFrequency = UpdateFrequencies(rawValue: picker.selectedRow(inComponent: 0)) {
                self.viewModel?.selectedFrequency = selectedFrequency
            }
            
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }))
        
        present(alertController, animated: true)
    }
}
