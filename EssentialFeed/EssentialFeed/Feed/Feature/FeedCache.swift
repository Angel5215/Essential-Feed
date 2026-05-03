//
// FeedCache.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

public protocol FeedCache {
    func save(_ feed: [FeedImage]) throws
}
