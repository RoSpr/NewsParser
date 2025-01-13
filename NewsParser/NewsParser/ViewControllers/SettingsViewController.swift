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
    
    private var pickerView: UIPickerView?
    private var pickerContainerView: UIView?
    
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
        return UpdateFrequenciesInMins(rawValue: row)?.getTextDescription()
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let selectedFrequency = UpdateFrequenciesInMins(rawValue: row) {
            viewModel?.selectedFrequency = selectedFrequency
        }
    }
}

//MARK: - UIPickerViewDataSource
extension SettingsViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        UpdateFrequenciesInMins.allCases.count
    }
}

//MARK: - Picker View
private extension SettingsViewController {
    func presentPickerView() {
        guard let viewModel = viewModel else { return }
        
        let containerHeight: CGFloat = 250
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.selectRow(viewModel.selectedFrequency.rawValue, inComponent: 0, animated: false)
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.overrideUserInterfaceStyle = .light
        self.pickerView = picker
        
        let effect = UIBlurEffect(style: .systemThickMaterialLight)
        let containerView = UIVisualEffectView(effect: effect)
        containerView.frame = CGRect(x: 5, y: view.frame.height, width: view.frame.width - 10, height: containerHeight)
        containerView.layer.cornerRadius = 10
        containerView.clipsToBounds = true
        
        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Готово", for: .normal)
        doneButton.addTarget(self, action: #selector(hidePickerView), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.contentView.addSubview(doneButton)
        containerView.contentView.addSubview(picker)
        
        NSLayoutConstraint.activate([
            doneButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            doneButton.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -10),
            doneButton.heightAnchor.constraint(equalToConstant: 21),
            
            picker.topAnchor.constraint(equalTo: doneButton.bottomAnchor, constant: 2),
            picker.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            picker.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            picker.rightAnchor.constraint(equalTo: containerView.rightAnchor),
        ])
        
        view.addSubview(containerView)
        self.pickerContainerView = containerView
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            containerView.frame.origin.y -= (containerHeight + self.view.safeAreaInsets.bottom + 10)
        }
    }
    
    @objc func hidePickerView() {
        guard let pickerContainerView = pickerContainerView else { return }
        
        UIView.animate(withDuration: 0.3, animations: {
            pickerContainerView.frame.origin.y += pickerContainerView.frame.height
        }) { _ in
            pickerContainerView.removeFromSuperview()
            self.pickerContainerView = nil
            self.pickerView = nil
        }
        
        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    }
}
