//
// FeedViewController.swift
// Copyright © 2025 Ángel Vázquez. All rights reserved.
//

import EssentialFeed
import UIKit

public final class FeedViewController: UITableViewController {
    private var loader: FeedLoader?
    private var onViewIsAppearing: ((FeedViewController) -> Void)?
    private var tableModel = [FeedImage]()

    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    public convenience init(loader: FeedLoader?) {
        self.init(nibName: nil, bundle: nil)
        self.loader = loader
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)

        onViewIsAppearing = { vc in
            vc.onViewIsAppearing = nil
            vc.load()
        }
    }

    override public func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        onViewIsAppearing?(self)
    }

    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableModel.count
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = tableModel[indexPath.row]
        let cell = FeedImageCell()
        cell.locationContainer.isHidden = cellModel.location == nil
        cell.locationLabel.text = cellModel.location
        cell.descriptionLabel.text = cellModel.description
        return cell
    }

    // MARK: - Helpers

    @objc private func load() {
        refreshControl?.beginRefreshing()
        loader?.load { [weak self] result in
            switch result {
            case let .success(feed):
                self?.tableModel = feed
                self?.tableView.reloadData()
                self?.refreshControl?.endRefreshing()

            case .failure:
                break
            }
        }
    }
}
