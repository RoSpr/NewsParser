//
//  RSSParserManager.swift
//  NewsParser
//
//  Created by Rodion on 26.12.2024.
//

import Foundation

protocol RSSParserManagerProtocol {
    func fetchAndParseRSS(from urlString: String) throws -> [RSSItemRaw]
    
}

final class RSSParserManager: RSSParserManagerProtocol {
    // Fetch RSS items in data format
    func fetchAndParseRSS(from urlString: String) throws -> [RSSItemRaw] {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, response, error) = URLSession.shared.synchronousDataTask(with: url)
        
        return parseRSS(data: data)
    }

    // Parse each RSS item from data into RSSItem struct
    private func parseRSS(data: Data?) -> [RSSItemRaw] {
        guard let data = data else { return [] }
        
        var items: [RSSItemRaw] = []

        let parser = XMLParser(data: data)
        let delegate = RSSParserDelegate { parsedItem in
            items.append(parsedItem)
        }
        parser.delegate = delegate
        let _ = parser.parse()
        
        return items
    }
}
