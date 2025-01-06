//
//  NewsCellViewModel.swift
//  NewsParser
//
//  Created by Rodion on 23.12.2024.
//

import Foundation
import UIKit

protocol NewsCellViewModel {
    var image: UIImage? { get }
    var hasImage: Bool { get }
    var newsHeader: String { get }
    var newsSource: String { get }
    var newsDate: String? { get }
    var isRead: Bool { get set }
    var downloadProgress: Double { get set }
}

final class NewsCellViewModelImpl: NewsCellViewModel {
    private let realmId: String
    
    lazy var image: UIImage? = ImageCacheManager.shared.fetchImage(for: realmId)
    
    var downloadProgress: Double = 0
    
    let hasImage: Bool
    let newsHeader: String
    let newsSource: String
    let newsDate: String?
    var isRead: Bool {
        didSet {
            DatabaseManager.shared.update {
                let rssItem = DatabaseManager.shared.fetch(RSSItem.self, predicate: NSPredicate(format: "id == %@", realmId))
                rssItem.first?.isRead = isRead
            }
        }
    }
    
    init(realmId: String, newsHeader: String, newsSource: String, date: Date, hasImage: Bool, isRead: Bool) {
        self.realmId = realmId
        self.hasImage = hasImage
        self.newsHeader = newsHeader
        self.newsSource = newsSource
        self.newsDate = Utils.getStringFromDate(date)
        self.isRead = isRead
    }
}
