//
// FeedLoaderPresentationAdapter.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import Combine
import EssentialFeed
import EssentialFeedMobile

final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
    private let feedLoader: () -> FeedLoader.Publisher
    private var cancellable: Cancellable?
    var presenter: FeedPresenter?

    init(feedLoader: @escaping () -> FeedLoader.Publisher) {
        self.feedLoader = feedLoader
    }

    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()

        cancellable = feedLoader()
            .dispatchOnMainQueue()
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    self?.presenter?.didFinishLoadingFeed(with: error)
                }
            } receiveValue: { [weak self] feed in
                self?.presenter?.didFinishLoadingFeed(with: feed)
            }
    }
}
