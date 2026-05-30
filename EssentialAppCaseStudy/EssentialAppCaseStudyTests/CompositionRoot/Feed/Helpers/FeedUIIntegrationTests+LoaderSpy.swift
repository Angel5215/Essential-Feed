//
// FeedUIIntegrationTests+LoaderSpy.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import EssentialAppCaseStudy
import EssentialFeed
import EssentialFeedMobile
import Foundation

extension FeedUIIntegrationTests {
    @MainActor
    final class LoaderSpy {
        // MARK: - FeedLoader

        private let feedLoader = EssentialAppCaseStudyTests.LoaderSpy<Void, Paginated<FeedImage>>()

        var loadFeedCallCount: Int {
            feedLoader.requests.count
        }

        func loadFeed() async throws -> Paginated<FeedImage> {
            try await feedLoader.load(from: ())
        }

        func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) async {
            let loadMore: @Sendable () async throws -> Paginated<FeedImage> = { @MainActor [weak self] in
                try await self?.loadMore() ?? Paginated(items: [])
            }

            await feedLoader.complete(with: Paginated(items: feed, loadMore: loadMore), at: index)
        }

        func completeFeedLoadingWithError(at index: Int = 0) async {
            await feedLoader.fail(with: anyNSError(), at: index)
        }

        // MARK: - LoadMoreFeedLoader

        private let loadMoreLoader = EssentialAppCaseStudyTests.LoaderSpy<Void, Paginated<FeedImage>>()

        var loadMoreCallCount: Int {
            loadMoreLoader.requests.count
        }

        func loadMore() async throws -> Paginated<FeedImage> {
            try await loadMoreLoader.load(from: ())
        }

        func completeLoadMore(with feed: [FeedImage] = [], lastPage: Bool = false, at index: Int = 0) async {
            let loadMore: @Sendable () async throws -> Paginated<FeedImage> = { @MainActor [weak self] in
                try await self?.loadMore() ?? Paginated(items: [])
            }

            await loadMoreLoader.complete(
                with: Paginated(items: feed, loadMore: lastPage ? nil : loadMore),
                at: index,
            )
        }

        func completeLoadMoreWithError(at index: Int = 0) async {
            await loadMoreLoader.fail(with: anyNSError(), at: index)
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

        func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) async {
            await imageLoader.complete(with: imageData, at: index)
        }

        func completeImageLoadingWithError(at index: Int = 0) async {
            await imageLoader.fail(with: anyNSError(), at: index)
        }

        func imageResult(at index: Int, timeout: TimeInterval = 1) async throws -> AsyncResult {
            try await imageLoader.result(at: index, timeout: timeout)
        }

        // MARK: - Common

        func cancelPendingRequests() async throws {
            try await imageLoader.cancelPendingRequests()
            try await feedLoader.cancelPendingRequests()
            try await loadMoreLoader.cancelPendingRequests()
        }
    }
}
