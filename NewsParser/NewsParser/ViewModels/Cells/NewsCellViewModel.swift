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
    var newsHeader: String { get }
    var newsSource: String { get }
    var newsDate: String? { get }
    var isRead: Bool { get set }
}

final class NewsCellViewModelImpl: NewsCellViewModel {
    let image: UIImage?
    let newsHeader: String
    let newsSource: String
    let newsDate: String?
    var isRead: Bool
    
    init(newsHeader: String, newsSource: String, date: Date) {
        self.image = nil
        self.newsHeader = newsHeader
        self.newsSource = newsSource
        self.newsDate = Utils.getStringFromDate(date)
        self.isRead = false
    }
}
