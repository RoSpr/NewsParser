//
//  RSSParserDelegate.swift
//  NewsParser
//
//  Created by Rodion on 26.12.2024.
//

import Foundation

class RSSParserDelegate: NSObject, XMLParserDelegate {
    private let onItemParsed: (RSSItemRaw) -> Void
    private var currentItem = RSSCurrentItem()
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
            currentItem = RSSCurrentItem()
        } else if elementName == "enclosure", attributeDict["type"] == "image/jpeg" {
            currentItem.imageLink = attributeDict["url"]
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentValue += string
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        let trimmedValue = currentValue.trimmingCharacters(in: .whitespacesAndNewlines)
        
        switch elementName {
        case "title":
            sourceTitle == nil ? (sourceTitle = trimmedValue) : (currentItem.title = trimmedValue)
        case "link":
            currentItem.link = trimmedValue
        case "pubDate":
            currentItem.pubDate = trimmedValue
        case "description":
            currentItem.description = trimmedValue
        case "item":
            if let title = currentItem.title,
               let link = currentItem.link,
               let pubDate = Utils.getDateFromString(currentItem.pubDate) {
                let raw = RSSItemRaw(realmId: nil, sourceTitle: sourceTitle ?? "Unknown", title: title, link: link, imageLink: currentItem.imageLink, description: currentItem.description, pubDate: pubDate, isRead: false, isImageDownloaded: false)
                onItemParsed(raw)
            }
        default: break
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: any Error) {
        print("Error occured: \(parseError)")
    }
}
