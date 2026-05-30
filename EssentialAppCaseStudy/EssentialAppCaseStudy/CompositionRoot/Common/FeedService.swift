//
// FeedService.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import CoreData
import EssentialFeed
import os

@MainActor
final class FeedService {
    private lazy var httpClient = makeRemoteClient()
    private lazy var store = makeLocalStore()
    private lazy var baseURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!
    private lazy var logger = Logger(subsystem: "me.vazquez.angel.EssentialAppCaseStudy", category: "main")

    convenience init(httpClient: HTTPClient, store: ScheduledStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
    }
}

// MARK: - Validate Cache

extension FeedService {
    func validateCache() {
        Task.immediate { @MainActor in
            await store.schedule { [store, logger] in
                do {
                    let localFeedLoader = LocalFeedLoader(store: store, currentDate: Date.init)
                    try localFeedLoader.validateCache()
                } catch {
                    logger.error("Failed to validate cache with error: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - Feed Image Loader & Pagination

extension FeedService {
    func loadRemoteFeedWithLocalFallback() async throws -> Paginated<FeedImage> {
        do {
            let feed = try await loadAndCacheRemoteFeed()
            return makeFirstPage(items: feed)
        } catch {
            let localFeed = try await loadLocalFeed()
            return makeFirstPage(items: localFeed)
        }
    }

    private func loadAndCacheRemoteFeed() async throws -> [FeedImage] {
        let feed = try await loadRemoteFeed()
        await store.schedule { [store] in
            let localFeedLoader = LocalFeedLoader(store: store, currentDate: Date.init)
            try? localFeedLoader.save(feed)
        }
        return feed
    }

    private func loadLocalFeed() async throws -> [FeedImage] {
        try await store.schedule { [store] in
            let localFeedLoader = LocalFeedLoader(store: store, currentDate: Date.init)
            return try localFeedLoader.load()
        }
    }

    private func loadRemoteFeed(after image: FeedImage? = nil) async throws -> [FeedImage] {
        let url = FeedEndpoint.get(after: image).url(baseURL: baseURL)
        let (data, response) = try await httpClient.get(from: url)
        return try FeedItemsMapper.map(data, from: response)
    }

    private func loadMoreRemoteFeed(last: FeedImage?) async throws -> Paginated<FeedImage> {
        async let cachedItems = loadLocalFeed()
        async let newItems = loadRemoteFeed(after: last)

        let items = try await cachedItems + newItems

        await store.schedule { [store] in
            let localFeedLoader = LocalFeedLoader(store: store, currentDate: Date.init)
            try? localFeedLoader.save(items)
        }

        return try await makePage(items: items, last: newItems.last)
    }

    private func makeFirstPage(items: [FeedImage]) -> Paginated<FeedImage> {
        makePage(items: items, last: items.last)
    }

    private func makePage(items: [FeedImage], last: FeedImage?) -> Paginated<FeedImage> {
        Paginated(items: items, loadMore: last.map { last in
            { @MainActor @Sendable in
                try await self.loadMoreRemoteFeed(last: last)
            }
        })
    }
}

// MARK: Feed Image Data Loader

extension FeedService {
    func loadLocalImageWithRemoteFallback(url: URL) async throws -> Data {
        do {
            return try await loadLocalImage(url: url)
        } catch {
            return try await loadAndCacheRemoteImage(url: url)
        }
    }

    private func loadLocalImage(url: URL) async throws -> Data {
        try await store.schedule { [store] in
            let localImageLoader = LocalFeedImageDataLoader(store: store)
            return try localImageLoader.loadImageData(from: url)
        }
    }

    private func loadAndCacheRemoteImage(url: URL) async throws -> Data {
        let (data, response) = try await httpClient.get(from: url)
        let imageData = try FeedImageDataMapper.map(data, from: response)
        await store.schedule { [store] in
            let localImageLoader = LocalFeedImageDataLoader(store: store)
            try? localImageLoader.save(data, for: url)
        }
        return imageData
    }
}

// MARK: - Image Comments Loader

extension FeedService {
    func loadComments(for image: FeedImage) -> () async throws -> [ImageComment] {
        { [httpClient, baseURL] in
            let url = ImageCommentsEndpoint.get(image.id).url(baseURL: baseURL)
            let (data, response) = try await httpClient.get(from: url)
            return try ImageCommentsMapper.map(data, from: response)
        }
    }
}

// MARK: - Factory helpers

extension FeedService {
    private func makeRemoteClient() -> HTTPClient {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }

    private func makeLocalStore() -> ScheduledStore {
        do {
            return try CoreDataFeedStore(
                storeURL: NSPersistentContainer.defaultDirectoryURL.appending(path: "feed-store.sqlite")
            )
        } catch {
            assertionFailure("Failed to instantiate CoreData store with error: \(error.localizedDescription)")
            logger.fault("Failed to instantiate CoreData store with error: \(error.localizedDescription)")
            return InMemoryFeedStore()
        }
    }
}
