//
//  String+Extensions.swift
//  NewsParser
//
//  Created by Rodion on 12.01.2025.
//

import Foundation

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
}
