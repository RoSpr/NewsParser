//
//  NewsListViewControllerViewModel.swift
//  NewsParser
//
//  Created by Rodion on 24.02.2025.
//

import UIKit

protocol NewsListViewControllerViewModel {
    var delegate: NewsListViewControllerDelegate? { get set }
    
    var networkManager: NetworkManagerProtocol { get }
    
    var numberOfSections: Int { get }
    func numberOfItemsInSection(section: Int, isInSearch: Bool) -> Int
    
    func itemAtIndex(indexPath: IndexPath, isInSearch: Bool) -> RSSItemRaw
    
    func fetchSources(sourceIds ids: [String]?)
    func shouldDownload(id: String) -> Bool
    func isDownloadInProgress(id: String) -> Bool
    
    func search(text: String)
    func getIndexOfItem(realmId: String?, needsFiltered: Bool) -> IndexPath?
}
