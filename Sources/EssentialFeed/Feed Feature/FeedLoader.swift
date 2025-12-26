//
// FeedLoader.swift
// Copyright © 2025 Ángel Vázquez. All rights reserved.
//

public typealias LoadFeedResult = Result<[FeedImage], Error>

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
