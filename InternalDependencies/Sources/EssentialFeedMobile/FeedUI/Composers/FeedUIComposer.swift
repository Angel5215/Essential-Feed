//
// FeedUIComposer.swift
// Copyright © 2025 Ángel Vázquez. All rights reserved.
//

import EssentialFeed
import UIKit

@MainActor
public enum FeedUIComposer {
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let feedPresenter = FeedPresenter()
        let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: feedLoader, presenter: feedPresenter)
        let refreshController = FeedRefreshViewController(delegate: presentationAdapter)
        let feedController = FeedViewController(refreshController: refreshController)

        feedPresenter.loadingView = WeakReferenceVirtualProxy(refreshController)
        feedPresenter.feedView = FeedViewAdapter(controller: feedController, imageLoader: imageLoader)

        return feedController
    }
}

private final class WeakReferenceVirtualProxy<Object: AnyObject> {
    private weak var object: Object?

    init(_ object: Object) {
        self.object = object
    }
}

extension WeakReferenceVirtualProxy: FeedLoadingView where Object: FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel) {
        object?.display(viewModel)
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

    func display(_ viewModel: FeedViewModel) {
        controller?.tableModel = viewModel.feed.map { model in
            let viewModel = FeedImageViewModel(model: model, imageLoader: imageLoader, imageTransformer: UIImage.init)
            return FeedImageCellController(viewModel: viewModel)
        }
    }
}

private final class FeedLoaderPresentationAdapter: FeedRefreshViewControllerDelegate {
    private let feedLoader: FeedLoader
    private let presenter: FeedPresenter

    init(feedLoader: FeedLoader, presenter: FeedPresenter) {
        self.feedLoader = feedLoader
        self.presenter = presenter
    }

    func didRequestFeedRefresh() {
        presenter.didStartLoadingFeed()
        feedLoader.load { [weak self] result in
            switch result {
            case let .success(feed):
                self?.presenter.didFinishLoadingFeed(with: feed)
            case let .failure(error):
                self?.presenter.didFinishLoadingFeed(with: error)
            }
        }
    }
}
