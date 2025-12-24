//
// CoreDataFeedStore.swift
// Copyright © 2025 Ángel Vázquez. All rights reserved.
//

import Foundation

public final class CoreDataFeedStore: FeedStore {
    public init() {}

    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }

    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {}

    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {}
}
