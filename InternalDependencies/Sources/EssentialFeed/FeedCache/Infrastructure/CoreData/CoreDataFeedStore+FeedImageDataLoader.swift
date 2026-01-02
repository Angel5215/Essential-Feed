//
// CoreDataFeedStore+FeedImageDataLoader.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import Foundation

extension CoreDataFeedStore: FeedImageDataStore {
    public func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        perform { context in
            completion(
                Result {
                    try ManagedFeedImage.first(with: url, in: context)?.data
                }
            )
        }
    }

    public func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
        perform { context in
            completion(
                Result {
                    try ManagedFeedImage.first(with: url, in: context)
                        .map { $0.data = data }
                        .map(context.save)
                }
            )
        }
    }
}
