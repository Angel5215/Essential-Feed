//
// SharedTestHelpers.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import EssentialFeed
import Foundation

func anyNSError() -> NSError {
    NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
    URL(string: "https://any-url.com")!
}

func anyData() -> Data {
    Data("any data".utf8)
}

func uniqueFeed() -> [FeedImage] {
    [
        FeedImage(id: UUID(), description: "any", location: "any", url: URL(string: "https://any-url.com")!)
    ]
}

// MARK: - Feed + Image Comments Localization

var loadError: String {
    LoadResourcePresenter<Any, DummyView>.loadError
}

var feedTitle: String {
    FeedPresenter.title
}

var commentsTitle: String {
    ImageCommentsPresenter.title
}

private final class DummyView: ResourceView {
    func display(_ viewModel: Any) {}
}
