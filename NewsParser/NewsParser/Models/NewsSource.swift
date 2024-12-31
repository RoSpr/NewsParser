//
//  NewsSource.swift
//  NewsParser
//
//  Created by Rodion on 26.12.2024.
//

import Foundation
import RealmSwift

class NewsSource: Object {
    @Persisted var id = UUID().uuidString
    @Persisted var name: String?
    @Persisted var stringURL: String
    @Persisted var isActive: Bool = true
    @Persisted var news: List<RSSItem>
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
