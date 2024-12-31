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
    
    func startFetchingIfNeeded() async
}

final class NewsListViewControllerViewModelImpl: NewsListViewControllerViewModel {
    private let queue: DispatchQueue = DispatchQueue(label: "com.newsListViewModel.queue", attributes: .concurrent)
    
    private var newsSources: [RSSItemRaw] = [] {
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
    
    func itemAtIndex(indexPath: IndexPath) -> RSSItemRaw {
        return newsSources[indexPath.row]
    }
    
    func startFetchingIfNeeded() async {
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

                                newsSource.news.append(objectsIn: items.map {
                                    let realmRSS = RSSItem()
                                    realmRSS.newsDescription = $0.description
                                    realmRSS.sourceTitle = $0.sourceTitle
                                    realmRSS.title = $0.title
                                    realmRSS.imageLink = $0.imageLink
                                    realmRSS.pubDate = $0.pubDate
                                    realmRSS.link = $0.link
                                    return realmRSS
                                })
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
