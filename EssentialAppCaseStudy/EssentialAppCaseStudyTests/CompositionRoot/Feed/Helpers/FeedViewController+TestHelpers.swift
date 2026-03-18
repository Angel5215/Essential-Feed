//
// FeedViewController+TestHelpers.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import EssentialFeedMobile
import UIKit

extension ListViewController {
    private var feedImagesSection: Int {
        0
    }

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

    func numberOfRenderedFeedImageViews() -> Int {
        tableView.numberOfSections == 0 ? 0 : tableView.numberOfRows(inSection: feedImagesSection)
    }

    func feedImageView(at row: Int) -> UITableViewCell? {
        guard numberOfRenderedFeedImageViews() > row else { return nil }
        let dataSource = tableView.dataSource
        let index = IndexPath(row: row, section: feedImagesSection)
        return dataSource?.tableView(tableView, cellForRowAt: index)
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

    // MARK: - Helpers

    private func prepareForFirstAppearance() {
        setSmallFrameToPreventRenderingCells()
        replaceRefreshControlWithFakeForiOS17OrLaterSupport()
    }

    private func setSmallFrameToPreventRenderingCells() {
        tableView.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
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
