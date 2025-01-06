//
//  NetworkManager.swift
//  NewsParser
//
//  Created by Rodion on 29.12.2024.
//

import Foundation

protocol NetworkManagerProtocol {
    func downloadContent(from url: URL, realmId: String, completion: @escaping (URL?, Error?) -> Void, progressUpdate: ((Double) -> Void)?)
    func addProgressObservers(progressObserver: ((Double) -> Void)?, completionObserver: ((URL?, Error?) -> Void)?, realmId: String)
}

final class NetworkManager: NSObject, NetworkManagerProtocol {
    private let downloadQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 10
        
        return queue
    }()
    
    private let urlSession = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
    private var downloadObservations: [Int: NSKeyValueObservation] = [:]
    
    private var progressObservers: [String: [((Double) -> Void)?]] = [:]
    private var downloadCompletedObservers: [String: [((URL?, Error?) -> Void)?]] = [:]
    
    func downloadContent(from url: URL, realmId: String, completion: @escaping (URL?, Error?) -> Void, progressUpdate: ((Double) -> Void)?) {
        downloadQueue.addOperation { [weak self] in
            guard let self = self else { return }
            
            self.addProgressObservers(progressObserver: progressUpdate, completionObserver: completion, realmId: realmId)
            
            let task = self.urlSession.downloadTask(with: url) { (localURL, response, error) in
                if let error = error {
                    self.downloadCompletion(realmId: realmId, url: nil, error: error)
                    return
                }
                
                guard let localURL = localURL else {
                    self.downloadCompletion(realmId: realmId, url: nil, error: NSError(domain: "NetworkManagerError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get data from the URL: \(url.absoluteString)"]))
                    return
                }
                
                self.downloadCompletion(realmId: realmId, url: localURL, error: nil)
            }
            
            let observation = task.progress.observe(\.fractionCompleted) { progress, _ in
                if progress.isFinished {
                    self.downloadObservations[task.taskIdentifier]?.invalidate()
                    self.progressObservers[realmId]?.removeAll()
                }
                
                self.progressObservers[realmId]?.forEach {
                    $0?(progress.fractionCompleted)
                }
            }
            
            downloadObservations[task.taskIdentifier] = observation
            
            task.resume()
        }
    }
    
    func addProgressObservers(progressObserver: ((Double) -> Void)?, completionObserver: ((URL?, Error?) -> Void)?, realmId: String) {
        if self.progressObservers[realmId] == nil {
            self.progressObservers[realmId] = []
        }
        
        if self.downloadCompletedObservers[realmId] == nil {
            self.downloadCompletedObservers[realmId] = []
        }
        
        self.progressObservers[realmId]?.append(progressObserver)
        self.downloadCompletedObservers[realmId]?.append(completionObserver)
    }

    private func downloadCompletion(realmId: String, url: URL?, error: Error?) {
        self.downloadCompletedObservers[realmId]?.forEach {
            $0?(url, error)
        }
        self.downloadCompletedObservers[realmId]?.removeAll()
    }
}
