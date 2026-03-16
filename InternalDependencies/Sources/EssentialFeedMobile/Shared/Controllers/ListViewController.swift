//
// ListViewController.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import EssentialFeed
import UIKit

public final class ListViewController: UITableViewController, UITableViewDataSourcePrefetching {
    @IBOutlet public private(set) var errorView: ErrorView?

    public var onRefresh: (() -> Void)?
    private var onViewIsAppearing: ((ListViewController) -> Void)?
    private var loadingControllers = [IndexPath: CellController]()

    private var tableModel = [CellController]() {
        didSet {
            tableView.reloadData()
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        onViewIsAppearing = { vc in
            vc.onViewIsAppearing = nil
            vc.refresh()
        }
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        tableView.sizeTableHeaderToFit()
    }

    @IBAction private func refresh() {
        onRefresh?()
    }

    override public func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        onViewIsAppearing?(self)
    }

    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableModel.count
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dataSource = cellController(forRowAt: indexPath).dataSource
        return dataSource.tableView(tableView, cellForRowAt: indexPath)
    }

    override public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let delegate = removeLoadingController(forRowAt: indexPath)?.delegate
        delegate?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }

    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let dataSourcePrefetching = cellController(forRowAt: indexPath).dataSourcePrefetching
            dataSourcePrefetching?.tableView(tableView, prefetchRowsAt: [indexPath])
        }
    }

    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let dataSourcePrefetching = removeLoadingController(forRowAt: indexPath)?.dataSourcePrefetching
            dataSourcePrefetching?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
        }
    }

    // MARK: - Helpers

    public func display(_ cellControllers: [CellController]) {
        loadingControllers = [:]
        tableModel = cellControllers
    }

    private func cellController(forRowAt indexPath: IndexPath) -> CellController {
        let controller = tableModel[indexPath.row]
        loadingControllers[indexPath] = controller
        return controller
    }

    private func removeLoadingController(forRowAt indexPath: IndexPath) -> CellController? {
        let controller = loadingControllers[indexPath]
        loadingControllers[indexPath] = nil
        return controller
    }
}

extension ListViewController: ResourceLoadingView {
    public func display(_ viewModel: ResourceLoadingViewModel) {
        refreshControl?.update(isRefreshing: viewModel.isLoading)
    }
}

extension ListViewController: ResourceErrorView {
    public func display(_ viewModel: ResourceErrorViewModel) {
        errorView?.message = viewModel.message
    }
}
