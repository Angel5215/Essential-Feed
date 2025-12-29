//
// FeedViewModel.swift
// Copyright © 2025 Ángel Vázquez. All rights reserved.
//

import EssentialFeed

final class FeedViewModel {
    private let feedLoader: FeedLoader

    var onChange: ((FeedViewModel) -> Void)?
    var onFeedLoad: (([FeedImage]) -> Void)?

    private(set) var isLoading = false {
        didSet {
            onChange?(self)
        }
    }

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    func loadFeed() {
        isLoading = true
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onFeedLoad?(feed)
            }
            self?.isLoading = false
        }
    }
}
