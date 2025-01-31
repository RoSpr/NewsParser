//
//  String+Extensions.swift
//  NewsParser
//
//  Created by Rodion on 12.01.2025.
//

import Foundation
import UIKit

fileprivate let htmlPattern = "(<[^>]+>)|(&\\w+;)"

extension String {
    func isValidURL() -> Bool {
        let pattern = #"^https?://(www\.)?[a-zA-Z0-9-\.]+\.[a-zA-Z]{2,}/.*"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return false
        }
        
        let range = NSRange(location: 0, length: self.utf16.count)
        return regex.firstMatch(in: self, options: [], range: range) != nil
    }
    
    func removeUrlPrefix() -> String {
        let pattern = "^(https?://)?(www\\.)?"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return self
        }
        
        let range = NSRange(location: 0, length: self.utf16.count)
        let modifiedString = regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "")
        
        return modifiedString
    }
    
    func removeHTMLTags() -> String {
        return self.replacingOccurrences(of: htmlPattern, with: "", options: .regularExpression)
    }
    
    func toAttributedString(font: UIFont = .systemFont(ofSize: 16)) -> NSAttributedString {
        let pattern = #"<a\s+[^>]*href="(.*?)"[^>]*>(.*?)</a>"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            let text = self.replacingOccurrences(of: htmlPattern, with: "", options: .regularExpression)
            return NSAttributedString(string: text, attributes: [.font: font])
        }
        
        let text = self.replacingOccurrences(of: htmlPattern, with: "", options: .regularExpression)
        let attributedString = NSMutableAttributedString(string: text, attributes: [.font: font])
        let nsText = self as NSString
        let range = NSRange(location: 0, length: nsText.length)
        
        let matches = regex.matches(in: self, options: [], range: range)
        
        for match in matches.reversed() {
            if let urlRange = Range(match.range(at: 1), in: self),
               let textRange = Range(match.range(at: 2), in: self) {
                let urlString = String(self[urlRange])
                let linkText = String(self[textRange])

                let rangeInAttrString = (attributedString.string as NSString).range(of: linkText)
                if rangeInAttrString.location != NSNotFound {
                    attributedString.addAttribute(.foregroundColor, value: UIColor.blue, range: rangeInAttrString)
                    attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: rangeInAttrString)
                    attributedString.addAttribute(.link, value: urlString, range: rangeInAttrString)
                }
            }
        }

        return attributedString
    }
}
