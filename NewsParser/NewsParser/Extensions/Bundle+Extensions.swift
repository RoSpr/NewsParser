//
//  Bundle_Extensions.swift
//  NewsParser
//
//  Created by Rodion on 31.01.2025.
//

import Foundation

extension Bundle {
    static var localized: Bundle {
        if let path = DatabaseManager.shared.retrieveValueFromUD(key: .selectedLanguage) as? String,
           let bundlePath = Bundle.main.path(forResource: path, ofType: "lproj"),
           let bundle = Bundle(path: bundlePath) {
            return bundle
        }
        return Bundle.main
    }
    
    class func setLanguage(_ language: String) {
        DatabaseManager.shared.saveValueToUD(key: .selectedLanguage, value: language)

        object_setClass(Bundle.main, type(of: localized))
    }
}
