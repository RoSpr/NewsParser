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
    
    private var memoryWarningsReceived: Int = 0
    
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
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveMemoryWarning), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
    }
    
    @objc private func didReceiveMemoryWarning() {
        memoryWarningsReceived += 1
        memoryCache.removeAllObjects()
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
                    NotificationCenter.default.post(name: .cacheSizeChanged, object: nil)
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
            if memoryWarningsReceived < 2 {
                queue.async { [weak self] in
                    self?.memoryCache.setObject(diskImageAndBytes.image, forKey: id as NSString, cost: diskImageAndBytes.bytes)
                }
            }
            image = diskImageAndBytes.image
        }
        
        return image
    }
    
    func deleteImageCache() {
        guard let path = cacheDirectory?.path else { return }
        
        do {
            let imageNames = try fileManager.contentsOfDirectory(atPath: path)
            for name in imageNames {
                try fileManager.removeItem(atPath: path.appending("/\(name)"))
            }
            memoryCache.removeAllObjects()
            NotificationCenter.default.post(name: .cacheSizeChanged, object: nil)
        } catch {
            print("Failed to clear cache: \(error)")
        }
    }
    
    func getStoredImagesSize() -> Int {
        guard let url = cacheDirectory else {
            print("No cache directory was found")
            return 0
        }
        
        let resourceKeys : [URLResourceKey] = [.fileSizeKey]
        guard let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: resourceKeys, options: [.skipsHiddenFiles], errorHandler: { (url, error) -> Bool in
            print("directoryEnumerator error at \(url): \(error)")
            return true
        }) else {
            print("Failed to create an enumerator")
            return 0
        }
        
        var totalSize: Int = 0
        for case let fileURL as URL in enumerator {
            let resourceValues = try? fileURL.resourceValues(forKeys: Set(resourceKeys))
            totalSize += resourceValues?.fileSize ?? 0
        }
        
        return totalSize
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
