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
    
//    private func presentPickerView() {
//        let pickerViewController = FrequencyPickerViewController()
//        pickerViewController.selectedFrequency = selectedFrequency
//        pickerViewController.onFrequencySelected = { [weak self] newFrequency in
//            self?.selectedFrequency = newFrequency
//            self?.tableView.reloadData()
//        }
//        navigationController?.pushViewController(pickerViewController, animated: true)
//    }
}

extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return (viewModel?.numberOfSections ?? 0)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfRowsIn(section: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.overrideUserInterfaceStyle = .light
        
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = "Частота обновления"
            cell.accessoryType = .disclosureIndicator
        case 1:
            let isVisible = viewModel?.isSourceVisible(at: indexPath.row) ?? false
            
            cell.textLabel?.text = viewModel?.getNewsSourceTitleOrLink(at: indexPath.row)
            cell.accessoryType = isVisible ? .checkmark : .none
        case 2:
            cell.textLabel?.text = "Очистить кэш"
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

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            break
        case 1:
            let cell = tableView.cellForRow(at: indexPath)
            cell?.accessoryType == .checkmark ? (cell?.accessoryType = .none) : (cell?.accessoryType = .checkmark)
            
            viewModel?.toggleNewsSourceVisibility(at: indexPath.row)
        case 2:
            DatabaseManager.shared.deleteAll()
        default: break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
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
