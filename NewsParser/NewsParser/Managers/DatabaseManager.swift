//
//  DatabaseManager.swift
//  NewsParser
//
//  Created by Rodion on 30.12.2024.
//

import Foundation
import RealmSwift

final class DatabaseManager {
    static let shared = DatabaseManager()

    private init() {}

    func getRealmInstance() -> Realm {
        do {
            return try Realm()
        } catch {
            fatalError("Error during initializing Realm: \(error)")
        }
    }

    func add<T: Object>(_ object: T) {
        let realm = getRealmInstance()
        do {
            try realm.write {
                realm.add(object)
            }
        } catch {
            print("Error adding object to Realm: \(error)")
        }
    }

    func delete<T: Object>(_ object: T) {
        let realm = getRealmInstance()
        do {
            try realm.write {
                realm.delete(object)
            }
        } catch {
            print("Error deleting object from Realm: \(error)")
        }
    }

    func update(_ block: () -> Void) {
        let realm = getRealmInstance()
        do {
            try realm.write(block)
        } catch {
            print("Error updating objects in Realm: \(error)")
        }
    }

    func fetch<T: Object>(_ type: T.Type, predicate: NSPredicate? = nil) -> Results<T> {
        let realm = getRealmInstance()
        var results = realm.objects(type)
        if let predicate = predicate {
            results = results.filter(predicate)
        }
        return results
    }

    func deleteAll() {
        let realm = getRealmInstance()
        do {
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            print("Error deleting all objects from Realm: \(error)")
        }
    }
    
    func fetchActiveNewsSources() -> [NewsSource] {
        let realm = getRealmInstance()
        
        let activeSources = realm.objects(NewsSource.self).filter("isActive == true")
        
        return Array(activeSources)
    }
    
    func fetchActiveRSSItemsRealm() -> [RSSItem] {
        let activeSources = fetchActiveNewsSources()
        
        let results = List<RSSItem>()
        
        activeSources.forEach {
            results.append(objectsIn: $0.news)
        }
        
        return Array(results)
    }
}
