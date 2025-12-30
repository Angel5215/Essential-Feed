//
// FeedPresenter.swift
// Copyright © 2025 Ángel Vázquez. All rights reserved.
//

import EssentialFeed
import Foundation

final class FeedPresenter {
    let feedView: FeedView
    let loadingView: FeedLoadingView
    let errorView: FeedErrorView

    static var title: String {
        String(localized: "FEED_VIEW_TITLE", table: "Feed", bundle: .module, comment: "Title for the feed view")
    }

    private var feedLoadError: String {
        String(localized: "FEED_VIEW_CONNECTION_ERROR", table: "Feed", bundle: .module, comment: "Error message displayed when we can't load the image feed from the server")
    }

    init(feedView: FeedView, loadingView: FeedLoadingView, errorView: FeedErrorView) {
        self.feedView = feedView
        self.loadingView = loadingView
        self.errorView = errorView
    }

    func didStartLoadingFeed() {
        loadingView.display(FeedLoadingViewModel(isLoading: true))
        errorView.display(FeedErrorViewModel(message: nil))
    }

    func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(FeedViewModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }

    func didFinishLoadingFeed(with error: Error) {
        loadingView.display(FeedLoadingViewModel(isLoading: false))
        errorView.display(FeedErrorViewModel(message: feedLoadError))
    }
}

// MARK: - Views

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}
