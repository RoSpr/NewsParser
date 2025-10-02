//
//  NetworkManager.swift
//  NewsParser
//
//  Created by Rodion on 29.12.2024.
//

import Foundation

protocol NetworkManagerProtocol {
    func downloadContent(from url: URL, realmId: String) async throws -> URL
    func observeProgress(for realmId: String) -> AsyncStream<Double>
}

final class NetworkManager: NSObject, NetworkManagerProtocol {
    private let downloadQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 10
        
        return queue
    }()
    
    private var progressSubjects: [String: AsyncStream<Double>.Continuation] = [:]
    private var urlSession: URLSession!
    
    override init() {
        super.init()
        
        urlSession = URLSession(configuration: .default, delegate: nil, delegateQueue: downloadQueue)
    }
    
    func downloadContent(from url: URL, realmId: String) async throws -> URL {
        let (localURL, _) = try await urlSession.download(from: url, delegate: nil)
        return localURL
    }
    
    //TODO: Fix the progress observation
    func observeProgress(for realmId: String) -> AsyncStream<Double> {
        AsyncStream { continuation in
            progressSubjects[realmId] = continuation
        }
    }
}
