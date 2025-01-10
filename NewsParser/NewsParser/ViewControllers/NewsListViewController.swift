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
    
    private let queue = DispatchQueue(label: "com.newsParser.newsListViewControllerQueue", attributes: .concurrent)
    
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
        
        self.tabBarController?.delegate = self
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
        if cell?.viewModel?.isRead == false {
            cell?.wasRead()
        }
        tableView.deselectRow(at: indexPath, animated: false)
        
        let newsDetailViewController = NewsDetailsViewController()
        if let viewModel = viewModel {
            let image = cell?.viewModel?.image
            
            let newsDetailViewModel = NewsDetailsViewControllerViewModelImpl(item: viewModel.itemAtIndex(indexPath: indexPath))
            newsDetailViewController.viewModel = newsDetailViewModel
            
            if let realmId = newsDetailViewModel.realmId, image == nil, viewModel.isDownloadInProgress(id: realmId) {
                newsDetailViewController.setInitialDownloadProgress(cell?.viewModel?.downloadProgress)
                viewModel.networkManager.addProgressObservers(progressObserver: newsDetailViewController.downloadProgressHandler, completionObserver: nil, realmId: realmId)
            }
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
              let rssItem = viewModel?.itemAtIndex(indexPath: indexPath),
              let realmId = rssItem.realmId,
              let viewModel = viewModel else {
            print("Failed to get cell, rssItem at index, realmId, or viewModel")
            return UITableViewCell(style: .default, reuseIdentifier: nil)
        }
        
        let cellViewModel = NewsCellViewModelImpl(realmId: realmId,
                                                   newsHeader: rssItem.title,
                                                   newsSource: rssItem.sourceTitle,
                                                   date: rssItem.pubDate,
                                                   hasImage: rssItem.imageLink != nil,
                                                   isRead: rssItem.isRead)
        cell.set(viewModel: cellViewModel)
        
        if !rssItem.isImageDownloaded, viewModel.shouldDownload(id: realmId), let imageLink = rssItem.imageLink, let url = URL(string: imageLink) {
            viewModel.networkManager.downloadContent(from: url, realmId: realmId, completion: { [weak self] localURL, error in
                self?.queue.async {
                    if let localURL = localURL, let data = try? Data(contentsOf: localURL), let image = UIImage(data: data) {
                        ImageCacheManager.shared.saveToDisk(image: image, forKey: realmId)
                        
                        if let savedItem = DatabaseManager.shared.fetch(RSSItem.self, predicate: NSPredicate(format: "id == %@", realmId)).first {
                            DatabaseManager.shared.update {
                                savedItem.isImageDownloaded = true
                            }
                        }
                        
                        cell.downloadCompletedHandler(image)
                        
                        DispatchQueue.main.async { [weak self] in
                            guard let self = self else { return }
                            self.tableView.reloadRows(at: [indexPath], with: .automatic)
                        }
                    } else if let error = error {
                        print("Failed to download image: \(error)")
                    }
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
        DispatchQueue.main.async { [weak self] in
            let insertedIndexPaths = insertions.map { IndexPath(row: $0, section: 0) }
            let updatedIndexPaths = updates.map { IndexPath(row: $0, section: 0) }
            
            self?.tableView.performBatchUpdates { [weak self] in
                self?.tableView.insertRows(at: insertedIndexPaths, with: .automatic)
                self?.tableView.reloadRows(at: updatedIndexPaths, with: .automatic)
            }
        }
    }
}

//MARK: - UITabBarControllerDelegate
extension NewsListViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let navController = viewController as? UINavigationController,
              navController.tabBarItem.tag == 0,
              self.view.window != nil else { return }
        
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
}
