//
// SceneDelegate.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import CoreData
import EssentialFeed
import EssentialFeedMobile
import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private lazy var httpClient = makeRemoteClient()
    private lazy var store = makeLocalStore()
    private lazy var localFeedLoader = makeLocalFeedLoader()
    private lazy var remoteFeedLoader = makeRemoteFeedLoader()

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
        window?.rootViewController = UINavigationController(
            rootViewController: FeedUIComposer.feedComposedWith(
                feedLoader: makeRemoteFeedLoaderWithLocalFallback,
                imageLoader: makeLocalImageLoaderWithRemoteFallback,
            )
        )
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

    private func makeRemoteFeedLoader() -> RemoteFeedLoader {
        let remoteURL = URL(string: "https://static1.squarespace.com/static/5891c5b8d1758ec68ef5dbc2/t/5db4155a4fbade21d17ecd28/1572083034355/essential_app_feed.json")!
        return RemoteFeedLoader(url: remoteURL, client: httpClient)
    }

    private func makeLocalFeedLoader() -> LocalFeedLoader {
        LocalFeedLoader(store: store, currentDate: Date.init)
    }

    private func makeRemoteFeedLoaderWithLocalFallback() -> FeedLoader.Publisher {
        remoteFeedLoader
            .loadPublisher()
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
    }

    private func makeLocalImageLoaderWithRemoteFallback(url: URL) -> FeedImageDataLoader.Publisher {
        let remoteImageLoader = RemoteFeedImageDataLoader(client: httpClient)
        let localImageLoader = LocalFeedImageDataLoader(store: store)

        return localImageLoader
            .loadImageDataPublisher(from: url)
            .fallback {
                remoteImageLoader
                    .loadImageDataPublisher(from: url)
                    .caching(to: localImageLoader, using: url)
            }
    }
}

extension RemoteLoader: FeedLoader where Resource == [FeedImage] {}
