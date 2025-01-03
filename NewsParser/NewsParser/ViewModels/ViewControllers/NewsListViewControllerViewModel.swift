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
    
    func startFetchingIfNeeded()
}

final class NewsListViewControllerViewModelImpl: NewsListViewControllerViewModel {
    private let queue: DispatchQueue = DispatchQueue(label: "com.newsListViewModel.queue", attributes: .concurrent)
    
    private var newsSources: [RSSItemRaw] = []
    
    init() {
        fetchSavedRSSItems()
        addNotificationToken()
    }
    
    lazy var networkManager: NetworkManagerProtocol = NetworkManager()
    
    weak var delegate: NewsListViewControllerDelegate? = nil
    
    var numberOfSections: Int { return 1 }
    
    func numberOfItemsInSection(section: Int) -> Int {
        return newsSources.count
    }
    
    func itemAtIndex(indexPath: IndexPath) -> RSSItemRaw {
        return newsSources[indexPath.row]
    }
    
    func startFetchingIfNeeded() {
        Task {
            await withCheckedContinuation { continuation in
                queue.async {
                    let newsSources = DatabaseManager.shared.fetch(NewsSource.self)
                    
                    for newsSource in newsSources {
                        let existingLinks = Set(newsSource.news.map { $0.link })
                        let stringURL = newsSource.stringURL
                        
                        do {
                            let items = try RSSParserManager().fetchAndParseRSS(from: stringURL)
                                .filter { !existingLinks.contains($0.link) }
                            
                            if items.count > 0 {
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
    
    private func fetchSavedRSSItems() {
        let savedRSSItems = DatabaseManager.shared.fetchActiveRSSItemsRealm()
        let rssRawItems = savedRSSItems.map {
            RSSItemRaw(realmId: $0.id, sourceTitle: $0.sourceTitle, title: $0.title, link: $0.link, imageLink: $0.imageLink, description: $0.newsDescription, pubDate: $0.pubDate, isRead: $0.isRead, isImageDownloaded: $0.isImageDownloaded)
        }
        newsSources.append(contentsOf: rssRawItems)
        newsSources.sort(by: { $0.pubDate > $1.pubDate })
        delegate?.reloadData()
    }
    
    private func addNotificationToken() {
        DatabaseManager.shared.observeChanges(for: RSSItem.self) { [weak self] changes in
            guard let self = self else { return }
            
            switch changes {
            case .initial(_):
                break
            case .update(let allElements, deletions: _, insertions: let insertions, modifications: let updates):
                let newElements = insertions.map {
                    let rssItem = allElements[$0]
                    return RSSItemRaw(realmId: rssItem.id, sourceTitle: rssItem.sourceTitle, title: rssItem.title, link: rssItem.link, imageLink: rssItem.imageLink, description: rssItem.newsDescription, pubDate: rssItem.pubDate, isRead: rssItem.isRead, isImageDownloaded: rssItem.isImageDownloaded)
                }
                
                updates.forEach {
                    let item = allElements[$0]
                    if let index = self.newsSources.firstIndex(where: { $0.realmId == item.id }) {
                        var rawItem = self.newsSources[index]
                        rawItem.isRead = item.isRead
                        self.newsSources[index] = rawItem
                    }
                }
                
                self.newsSources.insert(contentsOf: newElements, at: 0)
                self.newsSources.sort(by: { $0.pubDate > $1.pubDate })
                self.delegate?.tableViewUpdated(insertions: insertions, deletions: [], updates: updates)
            case .error(let error):
                print("Error in Realm observer: \(error)")
            }
        }
    }
}
