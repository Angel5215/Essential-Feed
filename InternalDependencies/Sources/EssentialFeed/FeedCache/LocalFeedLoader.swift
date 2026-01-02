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

public extension LocalFeedLoader {
    typealias SaveResult = Result<Void, Error>

    func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] deletionResult in
            guard let self else { return }
            switch deletionResult {
            case .success:
                cache(feed, with: completion)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    private func cache(_ feed: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
        store.insert(feed.toLocal(), timestamp: currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}

// MARK: - Load

extension LocalFeedLoader: FeedLoader {
    public typealias LoadResult = FeedLoader.Result

    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self else { return }
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(cache?) where FeedCachePolicy.validate(cache.timestamp, against: currentDate()):
                completion(.success(cache.feed.toModels()))
            case .success:
                completion(.success([]))
            }
        }
    }
}

// MARK: - Validate cache

public extension LocalFeedLoader {
    typealias ValidationResult = Result<Void, Error>

    func validateCache(completion: @escaping (ValidationResult) -> Void = { _ in }) {
        store.retrieve { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure:
                store.deleteCachedFeed { _ in completion(.success(())) }
            case let .success(cache?) where !FeedCachePolicy.validate(cache.timestamp, against: currentDate()):
                store.deleteCachedFeed { _ in completion(.success(())) }
            case .success:
                completion(.success(()))
            }
        }
    }
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
