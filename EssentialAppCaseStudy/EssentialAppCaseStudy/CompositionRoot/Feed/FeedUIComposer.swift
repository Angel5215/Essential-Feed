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
        selection: @escaping (FeedImage) -> Void = { _ in },
    ) -> ListViewController {
        let presentationAdapter = FeedPresentationAdapter(loader: feedLoader)
        let feedViewController = makeFeedViewController(title: FeedPresenter.title)
        feedViewController.onRefresh = presentationAdapter.loadResource
        presentationAdapter.presenter = LoadResourcePresenter(
            resourceView: FeedViewAdapter(
                controller: feedViewController,
                imageLoader: imageLoader,
                selection: selection,
            ),
            loadingView: WeakReferenceVirtualProxy(feedViewController),
            errorView: WeakReferenceVirtualProxy(feedViewController),
            mapper: FeedPresenter.map,
        )
        return feedViewController
    }

    // MARK: - Helpers

    private typealias FeedPresentationAdapter = LoadResourcePresentationAdapter<[FeedImage], FeedViewAdapter>

    private static func makeFeedViewController(title: String) -> ListViewController {
        let feedController = UIStoryboard.feed.instantiateInitialViewController() as! ListViewController
        feedController.title = title
        return feedController
    }
}
