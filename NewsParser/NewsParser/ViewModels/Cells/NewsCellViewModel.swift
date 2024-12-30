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
    var downloadedImageURL: URL? { get set }
    var newsHeader: String { get }
    var newsSource: String { get }
    var newsDate: String? { get }
    var isRead: Bool { get set }
}

final class NewsCellViewModelImpl: NewsCellViewModel {
    var image: UIImage? {
        if let url = downloadedImageURL {
            return UIImage(contentsOfFile: url.path)
        } else {
            return nil
        }
    }
    
    let hasImage: Bool
    var downloadedImageURL: URL? = nil
    
    let newsHeader: String
    let newsSource: String
    let newsDate: String?
    var isRead: Bool
    
    init(newsHeader: String, newsSource: String, date: Date, hasImage: Bool) {
        self.hasImage = hasImage
        self.newsHeader = newsHeader
        self.newsSource = newsSource
        self.newsDate = Utils.getStringFromDate(date)
        self.isRead = false
    }
}
