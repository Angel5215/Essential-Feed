//
// FeedImageDataLoaderSpy.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import EssentialFeed
import Foundation

final class FeedImageDataLoaderSpy: FeedImageDataLoader {
    private var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()

    var loadedURLs: [URL] { messages.map(\.url) }
    var cancelledURLs = [URL]()

    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        messages.append((url, completion))
        return Task { [weak self] in
            self?.cancelledURLs.append(url)
        }
    }

    func complete(with error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }

    func complete(with data: Data, at index: Int = 0) {
        messages[index].completion(.success(data))
    }

    // MARK: - Helpers

    private struct Task: FeedImageDataLoaderTask {
        let callback: () -> Void

        func cancel() {
            callback()
        }
    }
}
