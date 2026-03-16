//
// ListViewController.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import EssentialFeed
import UIKit

public protocol CellController {
    func view(in tableView: UITableView) -> UITableViewCell
    func preload()
    func cancelLoad()
}

public extension CellController {
    func preload() {}
    func cancelLoad() {}
}

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
        cellController(forRowAt: indexPath).view(in: tableView)
    }

    override public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelCellControllerLoad(forRowAt: indexPath)
    }

    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            cellController(forRowAt: indexPath).preload()
        }
    }

    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelCellControllerLoad)
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

    private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
        loadingControllers[indexPath]?.cancelLoad()
        loadingControllers[indexPath] = nil
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
