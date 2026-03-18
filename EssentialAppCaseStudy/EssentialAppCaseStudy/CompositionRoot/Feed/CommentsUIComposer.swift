//
// CommentsUIComposer.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import Combine
import EssentialFeed
import EssentialFeedMobile
import UIKit

public enum CommentsUIComposer {
    public static func commentsComposedWith(commentsLoader: @escaping () -> AnyPublisher<[FeedImage], Error>) -> ListViewController {
        let presentationAdapter = FeedPresentationAdapter(loader: commentsLoader)
        let feedViewController = makeFeedViewController(title: FeedPresenter.title)
        feedViewController.onRefresh = presentationAdapter.loadResource
        presentationAdapter.presenter = LoadResourcePresenter(
            resourceView: FeedViewAdapter(
                controller: feedViewController,
                imageLoader: { _ in Empty<Data, Error>().eraseToAnyPublisher() },
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
