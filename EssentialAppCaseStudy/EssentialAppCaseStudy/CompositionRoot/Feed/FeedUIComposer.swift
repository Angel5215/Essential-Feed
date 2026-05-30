//
// FeedUIComposer.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import EssentialFeed
import EssentialFeedMobile
import UIKit

@MainActor
public enum FeedUIComposer {
    private typealias FeedPresentationAdapter = AsyncLoadResourcePresentationAdapter<Paginated<FeedImage>, FeedViewAdapter>

    public static func feedComposedWith(
        feedLoader: @MainActor @escaping () async throws -> Paginated<FeedImage>,
        imageLoader: @MainActor @escaping (URL) async throws -> Data,
        selection: @MainActor @escaping (FeedImage) -> Void = { _ in },
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
            mapper: { $0 },
        )
        return feedViewController
    }

    // MARK: - Helpers

    private static func makeFeedViewController(title: String) -> ListViewController {
        let feedController = UIStoryboard.feed.instantiateInitialViewController() as! ListViewController
        feedController.title = title
        return feedController
    }
}
