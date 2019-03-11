//
//  Cache.swift
//  Cycles
//

import Foundation

enum Caches: String {
    case rental = "rental"
}

typealias RentalCache = Cache<Rental>

protocol CacheProtocol {
    associatedtype Value
    func cache(_ value: Value, key: String) throws
    func load(forKey: String) -> Value?
    func clear(forKey: String)
}

// TODO: support default key value so we don't need to enter it all the time
class Cache<Value: Codable> {}

extension Cache: CacheProtocol {
    func cache(_ value: Value, key: String) throws {
        let data = try JSONEncoder().encode(value)
        UserDefaults.standard.set(data, forKey: key)
    }

    func load(forKey: String) -> Value? {
        guard let data = UserDefaults.standard.data(forKey: forKey) else {
            return nil
        }
        return try? JSONDecoder().decode(Value.self, from: data)
    }

    func clear(forKey: String) {
        UserDefaults.standard.removeObject(forKey: forKey)
    }
}
