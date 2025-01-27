//
//  ImageCacheManager.swift
//  NewsParser
//
//  Created by Rodion on 01.01.2025.
//

import Foundation
import UIKit

class ImageCacheManager {
    static let shared = ImageCacheManager()
    
    private let queue = DispatchQueue(label: "com.newsParser.imageCacheManagerQueue", attributes: .concurrent)
    
    private let memoryCache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private var cacheDirectory: URL? = nil
    
    private init() {
        queue.async { [weak self] in
            guard let self = self else { return }
            if let cachePath = self.fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
                self.cacheDirectory = cachePath.appendingPathComponent("ImageCache")
                
                guard let directory = self.cacheDirectory else {
                    print("No cache directory was found")
                    return
                }
                
                if !self.fileManager.fileExists(atPath: directory.path) {
                    try? self.fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
                }
                
                self.memoryCache.totalCostLimit = 10 * 1024 * 1024
            }
        }
    }
    
    private func loadFromDisk(forKey key: String) -> (image: UIImage, bytes: Int)? {
        guard let filePath = cacheDirectory?.appendingPathComponent(key),
              let data = try? Data(contentsOf: filePath),
              let image = UIImage(data: data) else { return nil }
        
        return (image, data.count)
    }
    
    func saveToDisk(image: UIImage, forKey key: String) {
        guard let data = image.pngData() else { return }
        queue.async { [weak self] in
            guard let self = self else { return }
            if let filePath = self.cacheDirectory?.appendingPathComponent(key) {
                do {
                    try data.write(to: filePath)
                    
                    NotificationCenter.default.post(name: .didFinishImageDownload, object: nil, userInfo: ["realmId": key])
                } catch {
                    print("Error saving image data to the file: \(error)")
                }
            }
        }
    }
    
    func fetchImage(for id: String?) -> UIImage? {
        guard let id = id else { return nil }
        
        var image: UIImage? = nil
        
        if let cachedImage = self.memoryCache.object(forKey: id as NSString) {
            image = cachedImage
        } else if let diskImageAndBytes = self.loadFromDisk(forKey: id) {
            queue.async { [weak self] in
                self?.memoryCache.setObject(diskImageAndBytes.image, forKey: id as NSString, cost: diskImageAndBytes.bytes)
            }
            image = diskImageAndBytes.image
        }
        
        return image
    }
}
