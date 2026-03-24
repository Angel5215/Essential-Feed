//
// ListViewController+TestHelpers.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import EssentialFeedMobile
import UIKit

// MARK: - Shared

extension ListViewController {
    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing == true
    }

    var errorMessage: String? {
        errorView.message
    }

    func simulateErrorViewTap() {
        errorView.simulateTap()
    }

    func simulateAppearance() {
        if !isViewLoaded {
            loadViewIfNeeded()
            prepareForFirstAppearance()
        }

        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }

    func simulateUserInitiatedReload() {
        refreshControl?.simulatePullToRefresh()
    }

    func numberOfRows(in section: Int) -> Int {
        tableView.numberOfSections > section ? tableView.numberOfRows(inSection: section) : 0
    }

    func cell(row: Int, section: Int) -> UITableViewCell? {
        guard numberOfRows(in: section) > row else { return nil }
        let dataSource = tableView.dataSource
        let index = IndexPath(row: row, section: section)
        return dataSource?.tableView(tableView, cellForRowAt: index)
    }

    // MARK: - Helpers

    private func prepareForFirstAppearance() {
        setSmallFrameToPreventRenderingCells()
        replaceRefreshControlWithFakeForiOS17OrLaterSupport()
    }

    private func setSmallFrameToPreventRenderingCells() {
        tableView.frame = CGRect(x: 0, y: 0, width: 390, height: 1)
    }

    private func replaceRefreshControlWithFakeForiOS17OrLaterSupport() {
        let fakeRefreshControl = FakeUIRefreshControl()

        refreshControl?.allTargets.forEach { target in
            refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { action in
                fakeRefreshControl.addTarget(target, action: Selector(action), for: .valueChanged)
            }
        }

        refreshControl = fakeRefreshControl
    }

    private final class FakeUIRefreshControl: UIRefreshControl {
        private var _isRefreshing = false

        override var isRefreshing: Bool {
            _isRefreshing
        }

        override func beginRefreshing() {
            _isRefreshing = true
        }

        override func endRefreshing() {
            _isRefreshing = false
        }
    }
}

// MARK: - Feed

extension ListViewController {
    private var feedImagesSection: Int {
        0
    }

    private var feedLoadMoreSection: Int {
        1
    }

    var isShowingLoadMoreFeedIndicator: Bool {
        loadMoreFeedCell()?.isLoading == true
    }

    var loadMoreFeedErrorMessage: String? {
        loadMoreFeedCell()?.message
    }

    func numberOfRenderedFeedImageViews() -> Int {
        numberOfRows(in: feedImagesSection)
    }

    func feedImageView(at row: Int) -> UITableViewCell? {
        cell(row: row, section: feedImagesSection)
    }

    @discardableResult
    func simulateFeedImageViewVisible(at index: Int) -> FeedImageCell? {
        feedImageView(at: index) as? FeedImageCell
    }

    @discardableResult
    func simulateFeedImageViewNotVisible(at index: Int) -> FeedImageCell? {
        let view = simulateFeedImageViewVisible(at: index)

        let delegate = tableView.delegate
        let index = IndexPath(row: index, section: feedImagesSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)

        return view
    }

    func simulateFeedImageViewNearVisible(at row: Int) {
        let dataSource = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImagesSection)
        dataSource?.tableView(tableView, prefetchRowsAt: [index])
    }

    func simulateFeedImageViewNotNearVisible(at row: Int) {
        simulateFeedImageViewNearVisible(at: row)

        let dataSource = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImagesSection)
        dataSource?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
    }

    func renderedFeedImageData(at index: Int) -> Data? {
        simulateFeedImageViewVisible(at: index)?.renderedImage
    }

    func simulateTapOnFeedImage(at row: Int) {
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedImagesSection)
        delegate?.tableView?(tableView, didSelectRowAt: index)
    }

    func simulateLoadMoreFeedAction() {
        guard let cell = loadMoreFeedCell() else { return }
        let delegate = tableView.delegate
        let index = IndexPath(row: 0, section: feedLoadMoreSection)
        delegate?.tableView?(tableView, willDisplay: cell, forRowAt: index)
    }

    private func loadMoreFeedCell() -> LoadMoreCell? {
        cell(row: 0, section: feedLoadMoreSection) as? LoadMoreCell
    }
}

// MARK: - Image Comments

extension ListViewController {
    private var commentsSection: Int {
        0
    }

    func numberOfRenderedComments() -> Int {
        numberOfRows(in: commentsSection)
    }

    func commentMessage(at row: Int) -> String? {
        commentView(at: row)?.messageLabel.text
    }

    func commentDate(at row: Int) -> String? {
        commentView(at: row)?.dateLabel.text
    }

    func commentUsername(at row: Int) -> String? {
        commentView(at: row)?.usernameLabel.text
    }

    private func commentView(at row: Int) -> ImageCommentCell? {
        cell(row: row, section: commentsSection) as? ImageCommentCell
    }
}
