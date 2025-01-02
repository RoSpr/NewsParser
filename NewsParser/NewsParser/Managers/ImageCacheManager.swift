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
            }
        }
    }
    
    private func loadFromDisk(forKey key: String) -> UIImage? {
        var image: UIImage?
        guard let filePath = cacheDirectory?.appendingPathComponent(key) else { return nil }
        if let data = try? Data(contentsOf: filePath) {
            image = UIImage(data: data)
        }
        return image
    }
    
    func saveToDisk(image: UIImage, forKey key: String) {
        guard let data = image.pngData() else { return }
        queue.async { [weak self] in
            guard let self = self else { return }
            if let filePath = self.cacheDirectory?.appendingPathComponent(key) {
                do {
                    try data.write(to: filePath)
                } catch {
                    print("Error saving image data to the file: \(error)")
                }
            }
        }
    }
    
    func fetchImage(for id: String) -> UIImage? {
        if let cachedImage = self.memoryCache.object(forKey: id as NSString) {
            return cachedImage
        } else if let diskImage = self.loadFromDisk(forKey: id) {
            queue.async { [weak self] in
                self?.memoryCache.setObject(diskImage, forKey: id as NSString)
            }
            return diskImage
        } else {
            return nil
        }
    }
}
