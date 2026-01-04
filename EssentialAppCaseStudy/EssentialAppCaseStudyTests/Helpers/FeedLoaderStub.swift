//
// FeedLoaderStub.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import EssentialFeed

final class FeedLoaderStub: FeedLoader {
    private let result: FeedLoader.Result

    init(result: FeedLoader.Result) {
        self.result = result
    }

    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        completion(result)
    }
}
