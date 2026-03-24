//
// SceneDelegate.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import Combine
import CoreData
import EssentialFeed
import EssentialFeedMobile
import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private lazy var httpClient = makeRemoteClient()
    private lazy var store = makeLocalStore()
    private lazy var localFeedLoader = makeLocalFeedLoader()

    private lazy var baseURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!

    private lazy var navigationController = UINavigationController(
        rootViewController: FeedUIComposer.feedComposedWith(
            feedLoader: makeRemoteFeedLoaderWithLocalFallback,
            imageLoader: makeLocalImageLoaderWithRemoteFallback,
            selection: showComments,
        )
    )

    convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
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
        localFeedLoader.validateCache { _ in }
    }

    // MARK: - Helpers

    private func makeRemoteClient() -> HTTPClient {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }

    private func makeLocalStore() -> FeedStore & FeedImageDataStore {
        try! CoreDataFeedStore(
            storeURL: NSPersistentContainer.defaultDirectoryURL.appending(path: "feed-store.sqlite")
        )
    }

    private func makeLocalFeedLoader() -> LocalFeedLoader {
        LocalFeedLoader(store: store, currentDate: Date.init)
    }

    private func makeRemoteFeedLoaderWithLocalFallback() -> AnyPublisher<Paginated<FeedImage>, Error> {
        httpClient
            .getPublisher(from: FeedEndpoint.get(after: .none).url(baseURL: baseURL))
            .tryMap(FeedItemsMapper.map)
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
            .map { items in
                Paginated(items: items, loadMorePublisher: self.makeRemoteLoadMoreLoader(items: items, last: items.last))
            }
            .eraseToAnyPublisher()
    }

    private func makeRemoteLoadMoreLoader(items: [FeedImage], last: FeedImage?) -> (() -> AnyPublisher<Paginated<FeedImage>, Error>)? {
        last.map { lastItem in
            let url = FeedEndpoint.get(after: lastItem).url(baseURL: baseURL)
            return { [httpClient, localFeedLoader] in
                httpClient
                    .getPublisher(from: url)
                    .tryMap(FeedItemsMapper.map)
                    .map { newItems in
                        let allItems = items + newItems
                        return Paginated(
                            items: allItems,
                            loadMorePublisher: self.makeRemoteLoadMoreLoader(items: allItems, last: newItems.last),
                        )
                    }
                    .caching(to: localFeedLoader)
                    .eraseToAnyPublisher()
            }
        }
    }

    private func makeLocalImageLoaderWithRemoteFallback(url: URL) -> FeedImageDataLoader.Publisher {
        let localImageLoader = LocalFeedImageDataLoader(store: store)

        return localImageLoader
            .loadImageDataPublisher(from: url)
            .fallback { [httpClient] in
                httpClient
                    .getPublisher(from: url)
                    .tryMap(FeedImageDataMapper.map)
                    .caching(to: localImageLoader, using: url)
            }
    }

    private func showComments(for image: FeedImage) {
        let url = ImageCommentsEndpoint.get(image.id).url(baseURL: baseURL)
        let commentsViewController = CommentsUIComposer.commentsComposedWith(commentsLoader: makeRemoteCommentsLoader(url: url))
        navigationController.pushViewController(commentsViewController, animated: true)
    }

    private func makeRemoteCommentsLoader(url: URL) -> () -> AnyPublisher<[ImageComment], Error> {
        { [httpClient] in
            httpClient
                .getPublisher(from: url)
                .tryMap(ImageCommentsMapper.map)
                .eraseToAnyPublisher()
        }
    }
}
