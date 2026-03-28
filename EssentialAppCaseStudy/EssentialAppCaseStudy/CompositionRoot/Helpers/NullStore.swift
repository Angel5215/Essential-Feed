//
// NullStore.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import EssentialFeed
import Foundation

final class NullStore {}

extension NullStore: FeedStore {
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        completion(.success(()))
    }

    func insert(_ feed: [EssentialFeed.LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        completion(.success(()))
    }

    func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.success(nil))
    }
}

extension NullStore: FeedImageDataStore {
    func retrieve(dataForURL url: URL) throws -> Data? {
        nil
    }

    func insert(_ data: Data, for url: URL) throws {}
}
