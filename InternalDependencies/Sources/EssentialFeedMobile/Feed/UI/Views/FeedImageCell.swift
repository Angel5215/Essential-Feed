//
// FeedImageCell.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import UIKit

public final class FeedImageCell: UITableViewCell {
    @IBOutlet public private(set) var locationContainer: UIView!
    @IBOutlet public private(set) var locationLabel: UILabel!
    @IBOutlet public private(set) var feedImageContainer: UIView!
    @IBOutlet public private(set) var feedImageView: UIImageView!
    @IBOutlet public private(set) var feedImageRetryButton: UIButton!
    @IBOutlet public private(set) var descriptionLabel: UILabel!

    var onRetry: (() -> Void)?
    var onReuse: (() -> Void)?

    override public func prepareForReuse() {
        super.prepareForReuse()
        onReuse?()
    }

    @IBAction private func retryButtonTapped() {
        onRetry?()
    }
}
