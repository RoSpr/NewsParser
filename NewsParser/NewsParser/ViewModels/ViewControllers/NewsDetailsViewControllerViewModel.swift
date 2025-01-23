//
//  NewsDetailsViewControllerViewModel.swift
//  NewsParser
//
//  Created by Rodion on 29.12.2024.
//

import Foundation
import UIKit

protocol NewsDetailsViewControllerViewModel {
    var title: String { get }
    var sourceTitle: String { get }
    var description: String { get }
    var hasImage: Bool { get }
    var image: UIImage? { get }
    var pubDate: String? { get }
    var realmId: String? { get }
    var link: String { get }
}

final class NewsDetailsViewControllerViewModelImpl: NewsDetailsViewControllerViewModel {
    private var rssItem: RSSItemRaw
    
    var title: String {
        rssItem.title
    }
    
    var sourceTitle: String {
        rssItem.sourceTitle
    }
    
    var description: String {
        rssItem.description ?? ""
    }
    
    var hasImage: Bool {
        rssItem.imageLink != nil
    }
    
    var image: UIImage? {
        ImageCacheManager.shared.fetchImage(for: self.realmId)
    }
    
    var pubDate: String? {
        Utils.getStringFromDate(rssItem.pubDate)
    }
    
    var realmId: String? {
        rssItem.realmId
    }
    
    var link: String {
        rssItem.link
    }
    
    init(item: RSSItemRaw) {
        self.rssItem = item
    }
}
