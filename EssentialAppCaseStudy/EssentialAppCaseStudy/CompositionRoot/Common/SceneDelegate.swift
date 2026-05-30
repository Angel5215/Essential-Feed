//
// SceneDelegate.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import CoreData
import EssentialFeed
import EssentialFeedMobile
import os
import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private lazy var feedService = FeedService()

    private lazy var navigationController = UINavigationController(
        rootViewController: FeedUIComposer.feedComposedWith(
            feedLoader: feedService.loadRemoteFeedWithLocalFallback,
            imageLoader: feedService.loadLocalImageWithRemoteFallback,
            selection: showComments,
        )
    )

    convenience init(httpClient: HTTPClient, store: ScheduledStore) {
        self.init()
        self.feedService = FeedService(httpClient: httpClient, store: store)
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
        feedService.validateCache()
    }

    private func showComments(for image: FeedImage) {
        let commentsViewController = CommentsUIComposer.commentsComposedWith(commentsLoader: feedService.loadComments(for: image))
        navigationController.pushViewController(commentsViewController, animated: true)
    }
}
