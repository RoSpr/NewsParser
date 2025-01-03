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
    
    var image: UIImage? = nil
    
    var pubDate: String? {
        Utils.getStringFromDate(rssItem.pubDate)
    }
    
    init(item: RSSItemRaw) {
        self.rssItem = item
        
        startImageDownloadIfNeeded()
    }
    
    private func startImageDownloadIfNeeded() {
        guard let urlString = rssItem.imageLink else { return }
        
    }
}
