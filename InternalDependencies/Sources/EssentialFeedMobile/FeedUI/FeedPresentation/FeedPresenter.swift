//
// FeedPresenter.swift
// Copyright © 2025 Ángel Vázquez. All rights reserved.
//

import EssentialFeed
import Foundation

final class FeedPresenter {
    let feedView: FeedView
    let loadingView: FeedLoadingView

    static var title: String {
        String(localized: "FEED_VIEW_TITLE", table: "Feed", bundle: .module, comment: "Title for the feed view")
    }

    init(feedView: FeedView, loadingView: FeedLoadingView) {
        self.feedView = feedView
        self.loadingView = loadingView
    }

    func didStartLoadingFeed() {
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }

    func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(FeedViewModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }

    func didFinishLoadingFeed(with error: Error) {
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}

extension FeedPresenter {
    static var bundle: Bundle { .module }
}

// MARK: - Views

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}
