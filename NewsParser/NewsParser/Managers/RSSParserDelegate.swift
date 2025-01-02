//
//  RSSParserDelegate.swift
//  NewsParser
//
//  Created by Rodion on 26.12.2024.
//

import Foundation

class RSSParserDelegate: NSObject, XMLParserDelegate {
    private let onItemParsed: (RSSItemRaw) -> Void
    private var currentItem: [String: String]? = nil
    private var currentElement: String = ""
    private var currentValue: String = ""
    
    private var sourceTitle: String? = nil

    init(onItemParsed: @escaping (RSSItemRaw) -> Void) {
        self.onItemParsed = onItemParsed
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        currentElement = elementName
        currentValue = ""
        if elementName == "item" {
            currentItem = [:]
        } else if elementName == "enclosure", attributeDict["type"] == "image/jpeg" {
            currentItem?["imageLink"] = attributeDict["url"]
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentValue += string
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            if let title = currentItem?["title"],
               let link = currentItem?["link"],
               let pubDate = Utils.getDateFromString(currentItem?["pubDate"]) {
                let description = currentItem?["description"]
                let imageLink = currentItem?["imageLink"]
                
                onItemParsed(RSSItemRaw(sourceTitle: sourceTitle ?? "Unknown", title: title, link: link, imageLink: imageLink, description: description, pubDate: pubDate, isRead: false, isImageDownloaded: false))
            }
            currentItem = nil
        } else if elementName == "title" && sourceTitle == nil {
            sourceTitle = currentValue.trimmingCharacters(in: .whitespacesAndNewlines)
        } else if currentItem != nil {
            currentItem?[elementName] = currentValue.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: any Error) {
        print("Error occured: \(parseError)")
    }
}
