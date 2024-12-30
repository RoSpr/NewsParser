//
//  NetworkManager.swift
//  NewsParser
//
//  Created by Rodion on 29.12.2024.
//

import Foundation

protocol NetworkManagerProtocol {
    func downloadContent(from url: URL, completion: @escaping (URL?, Error?) -> Void, progressUpdate: ((Double) -> Void)?)
}

final class NetworkManager: NSObject, NetworkManagerProtocol {
    private let downloadQueue = OperationQueue()
    private let urlSession = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
    private var downloadObservations: [Int: NSKeyValueObservation] = [:]
    
    func downloadContent(from url: URL, completion: @escaping (URL?, Error?) -> Void, progressUpdate: ((Double) -> Void)?) {
        downloadQueue.addOperation { [weak self] in
            guard let self = self else { return }
            
            let task = self.urlSession.downloadTask(with: url) { (localURL, response, error) in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                guard let localURL = localURL else {
                    completion(nil, NSError(domain: "NetworkManagerError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get data from the URL: \(url.absoluteString)"]))
                    return
                }
                
                completion(localURL, nil)
            }
            
            let observation = task.progress.observe(\.fractionCompleted) { progress, _ in
                if progress.isFinished {
                    self.downloadObservations[task.taskIdentifier]?.invalidate()
                }
                progressUpdate?(progress.fractionCompleted)
            }
            
            downloadObservations[task.taskIdentifier] = observation
            
            task.resume()
        }
    }
}
