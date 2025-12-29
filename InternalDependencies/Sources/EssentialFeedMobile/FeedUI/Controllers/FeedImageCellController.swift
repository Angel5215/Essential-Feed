//
// FeedImageCellController.swift
// Copyright © 2025 Ángel Vázquez. All rights reserved.
//

import UIKit

protocol FeedImageCellControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
}

@MainActor
final class FeedImageCellController: @preconcurrency FeedImageView {
    private let delegate: FeedImageCellControllerDelegate
    private lazy var cell = FeedImageCell()

    init(delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
    }

    func view() -> UITableViewCell {
        delegate.didRequestImage()
        return cell
    }

    func preload() {
        delegate.didRequestImage()
    }

    func cancelLoad() {
        delegate.didCancelImageRequest()
    }

    func display(_ model: FeedImageViewModel<UIImage>) {
        cell.locationContainer.isHidden = !model.hasLocation
        cell.locationLabel.text = model.location
        cell.descriptionLabel.text = model.description
        cell.feedImageView.image = model.image
        cell.feedImageContainer.isShimmering = model.isLoading
        cell.feedImageRetryButton.isHidden = !model.shouldRetry
        cell.onRetry = delegate.didRequestImage
    }
}
