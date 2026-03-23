//
// LoadMoreCell.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import UIKit

public final class LoadMoreCell: UITableViewCell {
    private lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
        ])
        return spinner
    }()

    public var isLoading: Bool {
        get {
            spinner.isAnimating
        } set {
            if newValue {
                spinner.startAnimating()
            } else {
                spinner.stopAnimating()
            }
        }
    }
}
