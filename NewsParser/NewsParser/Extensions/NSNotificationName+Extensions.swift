//
//  NSNotificationName+Extensions.swift
//  NewsParser
//
//  Created by Rodion on 06.01.2025.
//

import Foundation

extension NSNotification.Name {
    public static let didFinishImageDownload = NSNotification.Name("didFinishImageDownload")
    public static let willEnterForeground = NSNotification.Name("willEnterForeground")
    public static let didEnterBackground = NSNotification.Name("didEnterBackground")
    public static let didChangeRefreshInterval = NSNotification.Name("didChangeRefreshInterval")
}
