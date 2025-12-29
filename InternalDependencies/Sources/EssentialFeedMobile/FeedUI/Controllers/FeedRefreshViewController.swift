//
// FeedRefreshViewController.swift
// Copyright © 2025 Ángel Vázquez. All rights reserved.
//

import UIKit

@MainActor
public final class FeedRefreshViewController: NSObject {
    public lazy var view: UIRefreshControl = bound(UIRefreshControl())
    private let viewModel: FeedViewModel

    init(viewModel: FeedViewModel) {
        self.viewModel = viewModel
    }

    @objc func refresh() {
        viewModel.loadFeed()
    }

    private func bound(_ view: UIRefreshControl) -> UIRefreshControl {
        viewModel.onLoadingStateChange = { [weak self] isLoading in
            if isLoading {
                self?.view.beginRefreshing()
            } else {
                self?.view.endRefreshing()
            }
        }
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
