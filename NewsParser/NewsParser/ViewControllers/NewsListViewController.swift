//
//  NewsListViewController.swift
//  NewsParser
//
//  Created by Rodion on 22.12.2024.
//

import Foundation
import UIKit

final class NewsListViewController: UIViewController {
    var viewModel: NewsListViewControllerViewModel?
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        
        tableView.register(NewsTableViewCell.self, forCellReuseIdentifier: NewsTableViewCell.identifier)
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubviews()
        setupConstraints()
        configure()
        setupNavigationBar()
        
        viewModel?.delegate = self
        viewModel?.startFetchingIfNeeded()
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
    
    private func configure() {
        overrideUserInterfaceStyle = .light
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Новости"
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

//MARK: - Table view delegate
extension NewsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? NewsTableViewCell
        cell?.viewModel?.isRead = true
        tableView.deselectRow(at: indexPath, animated: false)
        
        let newsDetailViewController = NewsDetailsViewController()
        if let viewModel = viewModel {
            let newsDetailViewModel = NewsDetailsViewControllerViewModelImpl(item: viewModel.itemAtIndex(indexPath: indexPath))
            newsDetailViewModel.image = cell?.viewModel?.image
            newsDetailViewController.viewModel = newsDetailViewModel
        }
        
        navigationController?.pushViewController(newsDetailViewController, animated: true)
    }
}

//MARK: - Table view data source
extension NewsListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel?.numberOfSections ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfItemsInSection(section: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsTableViewCell.identifier,
                                                       for: indexPath) as? NewsTableViewCell,
              let rssItem = viewModel?.itemAtIndex(indexPath: indexPath) else {
            return UITableViewCell(style: .default, reuseIdentifier: nil)
        }
        
        cell.viewModel = NewsCellViewModelImpl(newsHeader: rssItem.title,
                                               newsSource: rssItem.sourceTitle,
                                               date: rssItem.pubDate,
                                               hasImage: rssItem.imageLink != nil)
        
        if let imageLink = rssItem.imageLink, let url = URL(string: imageLink) {
            viewModel?.networkManager.downloadContent(from: url, completion: { localURL, error in
                if let localURL = localURL, let data = try? Data(contentsOf: localURL), let image = UIImage(data: data) {
                    cell.downloadCompletedHandler(image)
                    cell.viewModel?.downloadedImageURL = localURL
                } else if let error = error {
                    print("Failed to download image: \(error)")
                }
            }, progressUpdate: cell.downloadProgressHandler)
        }
        
        return cell
    }
}

//MARK: - NewsListViewControllerDelegate
extension NewsListViewController: NewsListViewControllerDelegate {
    func reloadData() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    func tableViewUpdated(insertions: [Int], deletions: [Int], updates: [Int]) {
        let insertedIndexPaths = insertions.map { IndexPath(row: $0, section: 0) }
        let updatedIndexPaths = updates.map { IndexPath(row: $0, section: 0) }
        
        tableView.performBatchUpdates { [weak self] in
            self?.tableView.insertRows(at: insertedIndexPaths, with: .automatic)
            self?.tableView.reloadRows(at: updatedIndexPaths, with: .automatic)
        }
    }
}
