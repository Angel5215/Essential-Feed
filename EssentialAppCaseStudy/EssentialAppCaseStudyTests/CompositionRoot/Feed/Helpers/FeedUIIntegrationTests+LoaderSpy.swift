//
// FeedUIIntegrationTests+LoaderSpy.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import Combine
import EssentialAppCaseStudy
import EssentialFeed
import EssentialFeedMobile
import UIKit

extension FeedUIIntegrationTests {
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

        private var imageLoader = EssentialAppCaseStudyTests.LoaderSpy<URL, Data>()

        var loadedImageURLs: [URL] {
            imageLoader.requests.map(\.parameter)
        }

        var cancelledImageURLs: [URL] {
            imageLoader.requests.filter { $0.result == .cancelled }.map(\.parameter)
        }

        func loadImageData(from url: URL) async throws -> Data {
            try await imageLoader.load(from: url)
        }

        func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
            imageLoader.complete(with: imageData, at: index)
        }

        func completeImageLoadingWithError(at index: Int = 0) {
            imageLoader.fail(with: anyNSError(), at: index)
        }

        func imageResult(at index: Int, timeout: TimeInterval = 1) async throws -> AsyncResult {
            try await imageLoader.result(at: index, timeout: timeout)
        }

        func cancelPendingRequests() async throws {
            try await imageLoader.cancelPendingRequests()
        }
    }
}
