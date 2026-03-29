//
// NullStore.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import EssentialFeed
import Foundation

final class NullStore {}

extension NullStore: FeedStore {
    func deleteCachedFeed() throws {}

    func insert(_ feed: [LocalFeedImage], timestamp: Date) throws {}

    func retrieve() throws -> CachedFeed? {
        nil
    }
}

extension NullStore: FeedImageDataStore {
    func retrieve(dataForURL url: URL) throws -> Data? {
        nil
    }

    func insert(_ data: Data, for url: URL) throws {}
}
