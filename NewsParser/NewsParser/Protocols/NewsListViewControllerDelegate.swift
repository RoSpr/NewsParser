//
//  NewsListViewControllerDelegate.swift
//  NewsParser
//
//  Created by Rodion on 29.12.2024.
//

import Foundation

protocol NewsListViewControllerDelegate: AnyObject {
    func reloadData()
    func tableViewUpdated(insertions: [Int], deletions: [Int], updates: [Int])
}
