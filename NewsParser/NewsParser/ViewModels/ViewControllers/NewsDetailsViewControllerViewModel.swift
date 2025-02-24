//
//  NewsDetailsViewControllerViewModel.swift
//  NewsParser
//
//  Created by Rodion on 29.12.2024.
//

import Foundation
import UIKit

final class NewsDetailsViewControllerViewModelImpl: NewsDetailsViewControllerViewModel {
    private var rssItem: RSSItemRaw
    
    var title: String {
        rssItem.title.removeHTMLTags()
    }
    
    var sourceTitle: String {
        rssItem.sourceTitle.removeHTMLTags()
    }
    
    var description: NSAttributedString {
        rssItem.description?.toAttributedString() ?? NSAttributedString(string: "")
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
