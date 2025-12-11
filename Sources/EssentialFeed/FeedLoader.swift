//
// FeedLoader.swift
// Copyright © 2025 Ángel Vázquez. All rights reserved.
//

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
