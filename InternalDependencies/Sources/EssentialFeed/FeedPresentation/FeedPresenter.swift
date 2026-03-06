//
// FeedPresenter.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

public enum FeedPresenter {
    public static var title: String {
        String(localized: "FEED_VIEW_TITLE", table: "Feed", bundle: .module, comment: "Title for the feed view")
    }

    public static func map(_ feed: [FeedImage]) -> FeedViewModel {
        FeedViewModel(feed: feed)
    }
}
