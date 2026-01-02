//
// LocalFeedImageDataLoader.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import Foundation

public final class LocalFeedImageDataLoader {
    private let store: FeedImageDataStore

    public init(store: FeedImageDataStore) {
        self.store = store
    }
}

// MARK: - Save

public extension LocalFeedImageDataLoader {
    typealias SaveResult = Swift.Result<Void, Error>

    func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
        store.insert(data, for: url) { _ in
        }
    }
}

extension LocalFeedImageDataLoader: FeedImageDataLoader {
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = LoadImageDataTask(completion)
        store.retrieve(dataForURL: url) { [weak self] result in
            guard self != nil else { return }
            task.complete(
                with: result
                    .mapError { _ in LoadError.failed }
                    .flatMap { data in
                        data.map { .success($0) } ?? .failure(LoadError.notFound)
                    },
            )
        }
        return task
    }

    public enum LoadError: Error {
        case failed
        case notFound
    }

    private final class LoadImageDataTask: FeedImageDataLoaderTask {
        var completion: ((FeedImageDataLoader.Result) -> Void)?

        init(_ completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }

        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }

        func cancel() {
            preventFurtherCompletions()
        }

        private func preventFurtherCompletions() {
            completion = nil
        }
    }
}
