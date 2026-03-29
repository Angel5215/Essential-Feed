//
// LocalFeedLoader.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import Foundation

public final class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date

    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
}

// MARK: - Save

extension LocalFeedLoader: FeedCache {
    public typealias SaveResult = FeedCache.Result

    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        completion(
            SaveResult {
                try store.deleteCachedFeed()
                try store.insert(feed.toLocal(), timestamp: currentDate())
            }
        )
    }
}

// MARK: - Load

public extension LocalFeedLoader {
    typealias LoadResult = Result<[FeedImage], Error>

    func load(completion: @escaping (LoadResult) -> Void) {
        completion(
            LoadResult {
                if let cache = try store.retrieve(), FeedCachePolicy.validate(cache.timestamp, against: currentDate()) {
                    cache.feed.toModels()
                } else {
                    []
                }
            }
        )
    }
}

// MARK: - Validate cache

public extension LocalFeedLoader {
    typealias ValidationResult = Result<Void, Error>

    func validateCache(completion: @escaping (ValidationResult) -> Void) {
        completion(
            ValidationResult {
                do {
                    if let cache = try store.retrieve(), !FeedCachePolicy.validate(cache.timestamp, against: currentDate()) {
                        throw InvalidCache()
                    }
                } catch {
                    try store.deleteCachedFeed()
                }
            }
        )
    }

    private struct InvalidCache: Error {}
}

private extension [FeedImage] {
    func toLocal() -> [LocalFeedImage] {
        map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}

private extension [LocalFeedImage] {
    func toModels() -> [FeedImage] {
        map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}
