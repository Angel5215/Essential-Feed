//
// RemoteFeedImageDataLoader.swift
// Copyright © 2025 Ángel Vázquez. All rights reserved.
//

import Foundation

public final class RemoteFeedImageDataLoader: FeedImageDataLoader {
    private let client: HTTPClient

    public init(client: HTTPClient) {
        self.client = client
    }

    public enum Error: Swift.Error {
        case invalidData
        case connectivity
    }

    @discardableResult
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = HTTPTaskWrapper(completion: completion)
        task.wrappedTask = client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success((data, response)) where response.statusCode == 200 && !data.isEmpty:
                task.complete(with: .success(data))
            case .success:
                task.complete(with: .failure(Error.invalidData))
            case .failure:
                task.complete(with: .failure(Error.connectivity))
            }
        }
        return task
    }

    // MARK: - Task

    private final class HTTPTaskWrapper: FeedImageDataLoaderTask {
        private var completion: ((FeedImageDataLoader.Result) -> Void)?
        var wrappedTask: HTTPClientTask?

        init(completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }

        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }

        func cancel() {
            preventFurtherCompletions()
            wrappedTask?.cancel()
        }

        private func preventFurtherCompletions() {
            completion = nil
        }
    }
}
