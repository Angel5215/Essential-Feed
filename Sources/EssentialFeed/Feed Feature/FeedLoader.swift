//
// FeedLoader.swift
// Copyright © 2025 Ángel Vázquez. All rights reserved.
//

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
