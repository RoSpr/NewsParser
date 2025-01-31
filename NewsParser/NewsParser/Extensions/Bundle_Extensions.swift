//
//  Bundle_Extensions.swift
//  NewsParser
//
//  Created by Rodion on 31.01.2025.
//

import Foundation

fileprivate let selectedLanguageUDKey = "selectedLanguage_UDKey"

extension Bundle {
    static var localized: Bundle {
        if let path = UserDefaults.standard.string(forKey: selectedLanguageUDKey),
           let bundlePath = Bundle.main.path(forResource: path, ofType: "lproj"),
           let bundle = Bundle(path: bundlePath) {
            return bundle
        }
        return Bundle.main
    }
    
    class func setLanguage(_ language: String) {
        UserDefaults.standard.set(language, forKey: selectedLanguageUDKey)
        UserDefaults.standard.synchronize()

        object_setClass(Bundle.main, type(of: localized))
    }
}
