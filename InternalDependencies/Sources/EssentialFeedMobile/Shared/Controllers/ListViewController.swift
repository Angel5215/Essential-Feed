//
// ListViewController.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import EssentialFeed
import UIKit

public final class ListViewController: UITableViewController, UITableViewDataSourcePrefetching {
    public private(set) var errorView = ErrorView()

    public var onRefresh: (() -> Void)?
    private var onViewIsAppearing: ((ListViewController) -> Void)?

    private lazy var dataSource: UITableViewDiffableDataSource<Int, CellController> = UITableViewDiffableDataSource(tableView: tableView) { tableView, indexPath, controller in
        controller.dataSource.tableView(tableView, cellForRowAt: indexPath)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        dataSource.defaultRowAnimation = .fade
        tableView.dataSource = dataSource
        configureErrorView()

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

    override public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let delegate = cellController(at: indexPath)?.delegate
        delegate?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }

    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let dataSourcePrefetching = cellController(at: indexPath)?.dataSourcePrefetching
            dataSourcePrefetching?.tableView(tableView, prefetchRowsAt: [indexPath])
        }
    }

    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let dataSourcePrefetching = cellController(at: indexPath)?.dataSourcePrefetching
            dataSourcePrefetching?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
        }
    }

    // MARK: - Helpers

    public func display(_ cellControllers: [CellController]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, CellController>()
        snapshot.appendSections([0])
        snapshot.appendItems(cellControllers, toSection: 0)
        dataSource.applySnapshotUsingReloadData(snapshot)
    }

    private func cellController(at indexPath: IndexPath) -> CellController? {
        dataSource.itemIdentifier(for: indexPath)
    }

    private func configureErrorView() {
        let container = errorView.makeContainer()
        tableView.tableHeaderView = container
        errorView.onHide = { [weak self] in
            self?.tableView.beginUpdates()
            self?.tableView.sizeTableHeaderToFit()
            self?.tableView.endUpdates()
        }
    }
}

extension ListViewController: ResourceLoadingView {
    public func display(_ viewModel: ResourceLoadingViewModel) {
        refreshControl?.update(isRefreshing: viewModel.isLoading)
    }
}

extension ListViewController: ResourceErrorView {
    public func display(_ viewModel: ResourceErrorViewModel) {
        errorView.message = viewModel.message
    }
}
