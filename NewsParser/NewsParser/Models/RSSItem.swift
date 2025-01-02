//
//  RSSItem.swift
//  NewsParser
//
//  Created by Rodion on 26.12.2024.
//

import Foundation
import RealmSwift

class RSSItem: Object {
    @Persisted var id = UUID().uuidString
    @Persisted var sourceTitle: String
    @Persisted var title: String
    @Persisted var link: String
    @Persisted var imageLink: String?
    @Persisted var newsDescription: String?
    @Persisted var pubDate: Date
    @Persisted var isRead: Bool = false
    @Persisted var isImageDownloaded: Bool = false
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

struct RSSItemRaw {
    var realmId: String?
    var sourceTitle: String
    var title: String
    var link: String
    var imageLink: String?
    var description: String?
    var pubDate: Date
    var isRead: Bool
    var isImageDownloaded: Bool
}
