//
//  NewsListViewControllerViewModel.swift
//  NewsParser
//
//  Created by Rodion on 26.12.2024.
//

import Foundation

protocol NewsListViewControllerViewModel {
    var delegate: NewsListViewControllerDelegate? { get set }
    
    var networkManager: NetworkManagerProtocol { get }
    
    var numberOfSections: Int { get }
    func numberOfItemsInSection(section: Int) -> Int
    
    func itemAtIndex(indexPath: IndexPath) -> RSSItem
    
    func startFetchingIfNeeded()
}

final class NewsListViewControllerViewModelImpl: NewsListViewControllerViewModel {
    private var newsSources: [RSSItem] = [] {
        didSet {
            delegate?.reloadData()
        }
    }
    
    lazy var networkManager: NetworkManagerProtocol = NetworkManager()
    
    weak var delegate: NewsListViewControllerDelegate? = nil
    
    var numberOfSections: Int { return 1 }
    
    func numberOfItemsInSection(section: Int) -> Int {
        return newsSources.count
    }
    
    func itemAtIndex(indexPath: IndexPath) -> RSSItem {
        return newsSources[indexPath.row]
    }
    
    func startFetchingIfNeeded() {
        Task {
            newsSources = await RSSParserManager().fetchMultipleRSSFeeds(urls: ["https://www.vedomosti.ru/rss/articles.xml"])
                .sorted(by: { $0.pubDate > $1.pubDate })
        }
    }
}
