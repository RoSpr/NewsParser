//
//  RSSItem.swift
//  NewsParser
//
//  Created by Rodion on 26.12.2024.
//

import Foundation

struct RSSItem {
    let sourceTitle: String
    let title: String
    let link: String
    let imageLink: String?
    let description: String?
    let pubDate: Date
}
