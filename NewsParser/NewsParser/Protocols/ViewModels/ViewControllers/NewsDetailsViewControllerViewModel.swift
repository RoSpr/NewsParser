//
//  NewsDetailsViewControllerViewModel.swift
//  NewsParser
//
//  Created by Rodion on 24.02.2025.
//

import UIKit

protocol NewsDetailsViewControllerViewModel {
    var title: String { get }
    var sourceTitle: String { get }
    var description: NSAttributedString { get }
    var hasImage: Bool { get }
    var image: UIImage? { get }
    var pubDate: String? { get }
    var realmId: String? { get }
    var link: String { get }
}
