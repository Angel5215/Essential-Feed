//
// FeedUIIntegrationTests+Localization.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import EssentialFeed
import XCTest

extension FeedUIIntegrationTests {
    var loadError: String {
        LoadResourcePresenter<Any, DummyView>.loadError
    }

    var feedTitle: String {
        FeedPresenter.title
    }

    var commentsTitle: String {
        ImageCommentsPresenter.title
    }

    // MARK: - Helpers

    private final class DummyView: ResourceView {
        func display(_ viewModel: Any) {}
    }
}
