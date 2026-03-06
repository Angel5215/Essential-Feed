//
// FeedCache.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

public protocol FeedCache {
    typealias Result = Swift.Result<Void, Error>

    func save(_ feed: [FeedImage], completion: @escaping (Result) -> Void)
}
