//
// LocalFeedImageDataLoader.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import Foundation

public final class LocalFeedImageDataLoader {
    private let store: FeedImageDataStore

    public init(store: FeedImageDataStore) {
        self.store = store
    }
}

// MARK: - Save

extension LocalFeedImageDataLoader: FeedImageDataCache {
    public func save(_ data: Data, for url: URL) throws {
        do {
            try store.insert(data, for: url)
        } catch {
            throw SaveError.failed
        }
    }

    public enum SaveError: Error {
        case failed
    }
}

extension LocalFeedImageDataLoader: FeedImageDataLoader {
    public func loadImageData(from url: URL) throws -> Data {
        do {
            if let imageData = try store.retrieve(dataForURL: url) {
                return imageData
            }
        } catch {
            throw LoadError.failed
        }

        throw LoadError.notFound
    }

    public enum LoadError: Error {
        case failed
        case notFound
    }
}
