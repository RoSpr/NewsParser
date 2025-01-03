//
//  Utils.swift
//  NewsParser
//
//  Created by Rodion on 28.12.2024.
//

import Foundation

struct Utils {
    static func getDateFromString(_ string: String?, format: String = "E, dd MMM yyyy HH:mm:ss Z") -> Date? {
        guard let string = string else { return nil }
        
        let formatter = DateFormatter()
        formatter.dateFormat = format
        
        return formatter.date(from: string)
    }
    
    static func getStringFromDate(_ date: Date?, format: String = "dd-MM-yyyy, HH:mm") -> String? {
        guard let date else { return nil }
        
        let formatter = DateFormatter()
        formatter.dateFormat = format
        
        return formatter.string(from: date)
    }
}
