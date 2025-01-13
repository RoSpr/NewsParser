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
    
    func itemAtIndex(indexPath: IndexPath) -> RSSItemRaw
    
    func fetchSources(sourceIds ids: [String]?)
    func shouldDownload(id: String) -> Bool
    func isDownloadInProgress(id: String) -> Bool
}

final class NewsListViewControllerViewModelImpl: NewsListViewControllerViewModel {
    private let queue: DispatchQueue = DispatchQueue(label: "com.newsListViewModel.queue", attributes: .concurrent)
    
    private var activeSourcesIds: Set<String> = []
    private var newsItems: [RSSItemRaw] = []
    private var downloadingIds: Set<String> = []
    
    private var updateTimer: Timer?
    
    init() {
        fetchSavedRSSItems()
        addNotificationToken()
        setupObservers()
    }
    
    lazy var networkManager: NetworkManagerProtocol = NetworkManager()
    
    weak var delegate: NewsListViewControllerDelegate? = nil
    
    var numberOfSections: Int { return 1 }
    
    func numberOfItemsInSection(section: Int) -> Int {
        return newsItems.count
    }
    
    func itemAtIndex(indexPath: IndexPath) -> RSSItemRaw {
        return newsItems[indexPath.row]
    }
    
    func fetchSources(sourceIds ids: [String]? = nil) {
        Task {
            await withCheckedContinuation { continuation in
                queue.async {
                    var predicate: NSPredicate? = nil
                    if let ids = ids {
                        predicate = NSPredicate(format: "id IN %@", ids)
                    }
                    
                    let newsSources = DatabaseManager.shared.fetchActiveNewsSources(predicate: predicate)
                    
                    for newsSource in newsSources {
                        let existingLinks = Set(newsSource.news.map { $0.link })
                        let stringURL = newsSource.stringURL
                        
                        do {
                            let items = try RSSParserManager().fetchAndParseRSS(from: stringURL)
                                .filter { !existingLinks.contains($0.link) }
                            
                            if items.count > 0 {
                                DatabaseManager.shared.saveValueToUD(key: .lastRefreshDate, value: Date())
                                DatabaseManager.shared.update {
                                    if newsSource.name == nil {
                                        newsSource.name = items.first?.sourceTitle
                                    }
                                    
                                    let sortedItems = items.sorted { $0.pubDate > $1.pubDate }
                                    
                                    newsSource.news.insert(contentsOf: sortedItems.map {
                                        let realmRSS = RSSItem()
                                        realmRSS.newsDescription = $0.description
                                        realmRSS.sourceTitle = $0.sourceTitle
                                        realmRSS.title = $0.title
                                        realmRSS.imageLink = $0.imageLink
                                        realmRSS.pubDate = $0.pubDate
                                        realmRSS.link = $0.link
                                        
                                        return realmRSS
                                    }, at: 0)
                                }
                            }
                        } catch {
                            print("Error during parsing RSS items: \(error)")
                        }
                    }
                    continuation.resume()
                }
            }
        }
    }
    
    func shouldDownload(id: String) -> Bool {
        guard downloadingIds.contains(id) else {
            downloadingIds.insert(id)
            return true
        }
        return false
    }
    
    func isDownloadInProgress(id: String) -> Bool {
        return downloadingIds.contains(id)
    }
    
    //MARK: Private methods
    private func fetchSavedRSSItems() {
        if activeSourcesIds.count == 0 {
            activeSourcesIds = Set(Array(DatabaseManager.shared.fetchActiveNewsSources().map { $0.id }))
        }
        
        let savedRSSItems = DatabaseManager.shared.fetchActiveRSSItemsRealm()
        let rssRawItems = savedRSSItems.map {
            RSSItemRaw(realmId: $0.id, sourceTitle: $0.sourceTitle, title: $0.title, link: $0.link, imageLink: $0.imageLink, description: $0.newsDescription, pubDate: $0.pubDate, isRead: $0.isRead, isImageDownloaded: $0.isImageDownloaded)
        }
        newsItems = rssRawItems
        newsItems.sort(by: { $0.pubDate > $1.pubDate })
        delegate?.reloadData()
    }
    
    private func addNotificationToken() {
        DatabaseManager.shared.observeChanges(for: RSSItem.self) { [weak self] changes in
            guard let self = self else { return }
            
            switch changes {
            case .initial(_):
                break
            case .update(let allElements, deletions: let deletions, insertions: let insertions, modifications: let updates):
                let newElements = insertions.map {
                    let rssItem = allElements[$0]
                    return RSSItemRaw(realmId: rssItem.id, sourceTitle: rssItem.sourceTitle, title: rssItem.title, link: rssItem.link, imageLink: rssItem.imageLink, description: rssItem.newsDescription, pubDate: rssItem.pubDate, isRead: rssItem.isRead, isImageDownloaded: rssItem.isImageDownloaded)
                }
                
                updates.forEach {
                    let item = allElements[$0]
                    if let index = self.newsItems.firstIndex(where: { $0.realmId == item.id }) {
                        var rawItem = self.newsItems[index]
                        rawItem.isRead = item.isRead
                        rawItem.isImageDownloaded = item.isImageDownloaded
                        self.newsItems[index] = rawItem
                    }
                }
                
                self.newsItems.insert(contentsOf: newElements, at: 0)
                self.newsItems.sort(by: { $0.pubDate > $1.pubDate })
                
                let sortedInsertions = newElements.compactMap { newItem in
                    self.newsItems.firstIndex(where: { $0.realmId == newItem.realmId })
                }
                
                if deletions.count == self.newsItems.count {
                    self.newsItems.removeAll()
                    self.delegate?.reloadData()
                }
                
                self.delegate?.tableViewUpdated(insertions: sortedInsertions, deletions: [], updates: updates)
            case .error(let error):
                print("Error in Realm observer: \(error)")
            }
        }
        
        DatabaseManager.shared.observeChanges(for: NewsSource.self) { [weak self] changes in
            guard let self = self else { return }
            
            switch changes {
            case .initial(_):
                break
            case .update(let allSources, let deletions, let insertions, let updates):
                let ids = insertions.map { allSources[$0].id }
                if ids.count > 0 {
                    self.activeSourcesIds.formUnion(ids)
                    self.fetchSources(sourceIds: ids)
                }
                
                if updates.count > 0 || deletions.count > 0 {
                    let activeSourceIds = Set(allSources.filter { $0.isActive == true }.map { $0.id })
                    if self.activeSourcesIds != activeSourceIds {
                        self.activeSourcesIds = activeSourceIds
                        
                        self.fetchSavedRSSItems()
                    }
                }
            case .error(let error):
                print("Error in Realm observer: \(error)")
            }
        }
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: .willEnterForeground, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: .didEnterBackground, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeRefreshInterval), name: .didChangeRefreshInterval, object: nil)
    }
    
    @objc private func willEnterForeground() {
        setupTimer()
    }
    
    @objc private func didEnterBackground() {
        releaseTimer()
    }
    
    @objc private func didChangeRefreshInterval() {
        releaseTimer()
        setupTimer()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK: - Timer management
private extension NewsListViewControllerViewModelImpl {
    private func setupTimer() {
        guard updateTimer == nil else { return }
        
        let lastRefreshDate = DatabaseManager.shared.retrieveValueFromUD(key: .lastRefreshDate) as? Date ?? Date()
        let frequency = UpdateFrequencies(rawValue: (DatabaseManager.shared.retrieveValueFromUD(key: .refreshInterval) as? Int ?? 0))
        let savedTimeInterval = Double((frequency?.getIntValue() ?? UpdateFrequencies.fiveMin.getIntValue()) * 60)
        
        let timeDiff = (Date().timeIntervalSince1970 - lastRefreshDate.timeIntervalSince1970)
        let timeInterval = savedTimeInterval - timeDiff
        
        if timeInterval < 0 {
            fetchSources()
        } else {
            DispatchQueue.main.async { [weak self] in
                guard let self = self, self.updateTimer == nil else { return }
                self.updateTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(self.fetchSourcesFromTimer), userInfo: nil, repeats: true)
            }
        }
    }
    
    private func releaseTimer() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    @objc private func fetchSourcesFromTimer() {
        fetchSources()
    }
}
