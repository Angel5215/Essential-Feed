//
// SceneDelegate.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import CoreData
import EssentialFeed
import EssentialFeedMobile
import os
import UIKit

typealias ScheduledStore = FeedImageDataStore & FeedStore & Sendable & StoreScheduler

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private lazy var httpClient = makeRemoteClient()

    private lazy var store = makeLocalStore()

    private lazy var baseURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!

    private lazy var logger = Logger(subsystem: "me.vazquez.angel.EssentialAppCaseStudy", category: "main")

    private lazy var navigationController = UINavigationController(
        rootViewController: FeedUIComposer.feedComposedWith(
            feedLoader: loadRemoteFeedWithLocalFallback,
            imageLoader: loadLocalImageWithRemoteFallback,
            selection: showComments,
        )
    )

    convenience init(httpClient: HTTPClient, store: ScheduledStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        window = UIWindow(windowScene: windowScene)
        configureWindow()
    }

    func configureWindow() {
        window?.backgroundColor = .systemBackground
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        validateCache()
    }

    // MARK: - Helpers

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

    private func showComments(for image: FeedImage) {
        let url = ImageCommentsEndpoint.get(image.id).url(baseURL: baseURL)
        let commentsViewController = CommentsUIComposer.commentsComposedWith(commentsLoader: loadComments(url: url))
        navigationController.pushViewController(commentsViewController, animated: true)
    }

    private func loadComments(url: URL) -> () async throws -> [ImageComment] {
        { [httpClient] in
            let (data, response) = try await httpClient.get(from: url)
            return try ImageCommentsMapper.map(data, from: response)
        }
    }

    private func validateCache() {
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

    // MARK: - Pagination

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

    // MARK: - Feed Image Loader

    private func loadRemoteFeedWithLocalFallback() async throws -> Paginated<FeedImage> {
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

    // MARK: - Store

    private func loadLocalImageWithRemoteFallback(url: URL) async throws -> Data {
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

protocol StoreScheduler {
    @MainActor
    func schedule<T>(_ action: @Sendable @escaping () throws -> T) async rethrows -> T
}

extension CoreDataFeedStore: StoreScheduler {
    @MainActor
    func schedule<T>(_ action: @Sendable @escaping () throws -> T) async rethrows -> T {
        if contextQueue == .main {
            try action()
        } else {
            try await perform(action)
        }
    }
}

extension InMemoryFeedStore: StoreScheduler {
    @MainActor
    func schedule<T>(_ action: @Sendable @escaping () throws -> T) async rethrows -> T {
        try action()
    }
}
