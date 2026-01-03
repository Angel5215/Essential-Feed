//
// FeedImageDataLoaderWithFallbackComposite.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import EssentialFeed
import Foundation

public final class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    private let primary: FeedImageDataLoader
    private let fallback: FeedImageDataLoader

    public init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
        self.primary = primary
        self.fallback = fallback
    }

    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = Task()
        task.wrappedTask = primary.loadImageData(from: url) { [weak self] result in
            switch result {
            case .success:
                completion(result)
            case .failure:
                task.wrappedTask = self?.fallback.loadImageData(from: url, completion: completion)
            }
        }
        return task
    }

    private final class Task: FeedImageDataLoaderTask {
        var wrappedTask: FeedImageDataLoaderTask?

        func cancel() {
            wrappedTask?.cancel()
        }
    }
}
