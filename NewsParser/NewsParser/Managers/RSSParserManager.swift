//
//  RSSParserManager.swift
//  NewsParser
//
//  Created by Rodion on 26.12.2024.
//

import Foundation

protocol RSSParserManagerProtocol {
    func fetchMultipleRSSFeeds(urls: [String]) async -> [RSSItem]
    
}

final class RSSParserManager: RSSParserManagerProtocol {
    // Parse items from multiple RSS feeds into an array of items
    func fetchMultipleRSSFeeds(urls: [String]) async -> [RSSItem] {
        await withTaskGroup(of: [RSSItem]?.self) { group in
            var results: [RSSItem] = []

            for url in urls {
                group.addTask { [weak self] in
                    guard let self = self else { return nil }
                    
                    do {
                        return try await self.fetchAndParseRSS(from: url)
                    } catch {
                        print("Failed to fetch \(url): \(error)")
                        return nil
                    }
                }
            }

            for await result in group {
                if let items = result {
                    results.append(contentsOf: items)
                }
            }

            return results
        }
    }
    
    // Fetch RSS items in data format
    private func fetchAndParseRSS(from urlString: String) async throws -> [RSSItem] {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        
        return parseRSS(data: data)
    }

    // Parse each RSS item from data into RSSItem struct
    private func parseRSS(data: Data) -> [RSSItem] {
        var items: [RSSItem] = []

        let parser = XMLParser(data: data)
        let delegate = RSSParserDelegate { parsedItem in
            items.append(parsedItem)
        }
        parser.delegate = delegate
        let _ = parser.parse()
        
        return items
    }
}
