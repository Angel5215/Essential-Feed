//
// FeedRefreshViewController.swift
// Copyright © 2025 Ángel Vázquez. All rights reserved.
//

import UIKit

protocol FeedRefreshViewControllerDelegate {
    func didRequestFeedRefresh()
}

@MainActor
public final class FeedRefreshViewController: NSObject, @preconcurrency FeedLoadingView {
    @IBOutlet public var view: UIRefreshControl?
    var delegate: FeedRefreshViewControllerDelegate?

    @IBAction func refresh() {
        delegate?.didRequestFeedRefresh()
    }

    func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            view?.beginRefreshing()
        } else {
            view?.endRefreshing()
        }
    }
}
