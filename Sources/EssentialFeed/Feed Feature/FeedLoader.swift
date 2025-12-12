//
// FeedLoader.swift
// Copyright © 2025 Ángel Vázquez. All rights reserved.
//

public enum LoadFeedResult: Sendable {
    case success([FeedItem])
    case failure(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
