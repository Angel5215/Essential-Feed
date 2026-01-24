//
// FeedUIComposer.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import Combine
import EssentialFeed
import EssentialFeedMobile
import UIKit

public enum FeedUIComposer {
    public static func feedComposedWith(
        feedLoader: @escaping () -> AnyPublisher<[FeedImage], Error>,
        imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher,
    ) -> FeedViewController {
        let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: feedLoader)
        let feedController = makeFeedViewController(delegate: presentationAdapter, title: FeedPresenter.title)
        presentationAdapter.presenter = FeedPresenter(
            feedView: FeedViewAdapter(controller: feedController, imageLoader: imageLoader),
            loadingView: WeakReferenceVirtualProxy(feedController),
            errorView: WeakReferenceVirtualProxy(feedController),
        )
        return feedController
    }

    private static func makeFeedViewController(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
        let feedController = UIStoryboard.feed.instantiateInitialViewController() as! FeedViewController
        feedController.delegate = delegate
        feedController.title = title
        return feedController
    }
}
