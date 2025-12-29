//
// FeedUIComposer.swift
// Copyright © 2025 Ángel Vázquez. All rights reserved.
//

import EssentialFeed
import UIKit

@MainActor
public enum FeedUIComposer {
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let feedPresenter = FeedPresenter(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(presenter: feedPresenter)
        let feedController = FeedViewController(refreshController: refreshController)

        feedPresenter.loadingView = refreshController
        feedPresenter.feedView = FeedViewAdapter(controller: feedController, imageLoader: imageLoader)

        return feedController
    }

    private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewController, loader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
        { [weak controller] feed in
            controller?.tableModel = feed.map { model in
                let viewModel = FeedImageViewModel(model: model, imageLoader: loader, imageTransformer: UIImage.init)
                return FeedImageCellController(viewModel: viewModel)
            }
        }
    }
}

@MainActor
private final class FeedViewAdapter: @preconcurrency FeedView {
    private weak var controller: FeedViewController?
    private let imageLoader: FeedImageDataLoader

    init(controller: FeedViewController? = nil, imageLoader: FeedImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }

    func display(feed: [FeedImage]) {
        controller?.tableModel = feed.map { model in
            let viewModel = FeedImageViewModel(model: model, imageLoader: imageLoader, imageTransformer: UIImage.init)
            return FeedImageCellController(viewModel: viewModel)
        }
    }
}
