//
// FeedLoader.swift
// Copyright © 2025 Ángel Vázquez. All rights reserved.
//

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>

    func load(completion: @escaping (Result) -> Void)
}
