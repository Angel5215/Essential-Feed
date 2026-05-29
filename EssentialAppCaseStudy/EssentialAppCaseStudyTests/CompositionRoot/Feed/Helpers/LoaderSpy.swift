//
// LoaderSpy.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import Combine
import EssentialAppCaseStudy
import EssentialFeed
import EssentialFeedMobile
import UIKit

@MainActor
final class LoaderSpy {
    // MARK: - FeedLoader

    private var feedRequests = [PassthroughSubject<Paginated<FeedImage>, Error>]()

    var loadFeedCallCount: Int {
        feedRequests.count
    }

    func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
        feedRequests[index].send(
            Paginated(items: feed) { [weak self] in
                self?.loadMorePublisher() ?? Empty().eraseToAnyPublisher()
            }
        )
        feedRequests[index].send(completion: .finished)
    }

    func completeFeedLoadingWithError(at index: Int = 0) {
        let error = NSError(domain: "an error", code: 0)
        feedRequests[index].send(completion: .failure(error))
    }

    func completeLoadMore(with feed: [FeedImage] = [], lastPage: Bool = false, at index: Int = 0) {
        loadMoreRequests[index].send(
            Paginated(items: feed, loadMorePublisher: lastPage ? nil : { [weak self] in
                self?.loadMorePublisher() ?? Empty().eraseToAnyPublisher()
            })
        )
    }

    func completeLoadMoreWithError(at index: Int = 0) {
        loadMoreRequests[index].send(completion: .failure(anyNSError()))
    }

    func loadPublisher() -> AnyPublisher<Paginated<FeedImage>, Error> {
        let publisher = PassthroughSubject<Paginated<FeedImage>, Error>()
        feedRequests.append(publisher)
        return publisher.eraseToAnyPublisher()
    }

    // MARK: - LoadMoreFeedLoader

    private var loadMoreRequests = [PassthroughSubject<Paginated<FeedImage>, Error>]()

    var loadMoreCallCount: Int {
        loadMoreRequests.count
    }

    func loadMorePublisher() -> AnyPublisher<Paginated<FeedImage>, Error> {
        let publisher = PassthroughSubject<Paginated<FeedImage>, Error>()
        loadMoreRequests.append(publisher)
        return publisher.eraseToAnyPublisher()
    }

    // MARK: - FeedImageDataLoader

    enum AsyncResult {
        case success
        case failure
        case cancelled
    }

    private struct ImageRequest {
        var url: URL
        var publisher: AsyncThrowingStream<Data, Error>
        var continuation: AsyncThrowingStream<Data, Error>.Continuation
        var result: AsyncResult?
    }

    private struct NoResponse: Error {}
    private struct Timeout: Error {}

    private var imageRequests = [ImageRequest]()

    var loadedImageURLs: [URL] {
        imageRequests.map(\.url)
    }

    private(set) var cancelledImageURLs = [URL]()

    func loadImageData(from url: URL) async throws -> Data {
        let (stream, continuation) = AsyncThrowingStream<Data, Error>.makeStream()
        let index = imageRequests.count
        imageRequests.append(ImageRequest(url: url, publisher: stream, continuation: continuation))

        do {
            for try await result in stream {
                try Task.checkCancellation()
                imageRequests[index].result = .success
                return result
            }

            try Task.checkCancellation()

            throw NoResponse()
        } catch {
            if Task.isCancelled {
                cancelledImageURLs.append(url)
                imageRequests[index].result = .cancelled
            } else {
                imageRequests[index].result = .failure
            }
            throw error
        }
    }

    func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
        imageRequests[index].continuation.yield(imageData)
        imageRequests[index].continuation.finish()

        while imageRequests[index].result == nil {
            RunLoop.current.run(until: Date())
        }
    }

    func completeImageLoadingWithError(at index: Int = 0) {
        imageRequests[index].continuation.finish(throwing: anyNSError())

        while imageRequests[index].result == nil {
            RunLoop.current.run(until: Date())
        }
    }

    func imageResult(at index: Int, timeout: TimeInterval = 1) async throws -> AsyncResult {
        let maxDate = Date() + timeout

        while Date() <= maxDate {
            if let result = imageRequests[index].result {
                return result
            }

            await Task.yield()
        }

        throw Timeout()
    }

    func cancelPendingRequests() async throws {
        for (index, request) in imageRequests.enumerated() where request.result == nil {
            request.continuation.finish(throwing: CancellationError())

            while imageRequests[index].result == nil {
                await Task.yield()
            }
        }
    }
}
