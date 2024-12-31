//
//  URLSession+Extensions.swift
//  NewsParser
//
//  Created by Rodion on 31.12.2024.
//

import Foundation

extension URLSession {
    func synchronousDataTask(with url: URL) -> (Data?, URLResponse?, Error?) {
        var parsedData: Data?
        var parsedResponse: URLResponse?
        var parsedError: Error?
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            parsedData = data
            parsedResponse = response
            parsedError = error
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()

        return (parsedData, parsedResponse, parsedError)
    }
}
