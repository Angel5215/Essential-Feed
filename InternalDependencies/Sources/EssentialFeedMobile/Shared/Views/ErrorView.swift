//
// ErrorView.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import UIKit

public final class ErrorView: UIButton {
    public var message: String? {
        get { isVisible ? configuration?.title : nil }
        set { setMessageAnimated(newValue) }
    }

    public var onHide: (() -> Void)?

    private var titleAttributes: AttributeContainer {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        return AttributeContainer([
            .paragraphStyle: paragraphStyle,
            .font: UIFont.preferredFont(forTextStyle: .body),
        ])
    }

    private var isVisible: Bool {
        alpha > 0
    }

    // MARK: - Public interface

    override public init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    // MARK: - Private methods

    private func configure() {
        var configuration = Configuration.plain()
        configuration.titlePadding = 0
        configuration.baseForegroundColor = .white
        configuration.background.backgroundColor = .errorBackground
        configuration.background.cornerRadius = 0
        self.configuration = configuration
        addTarget(self, action: #selector(hideMessageAnimated), for: .touchUpInside)
        hideMessage()
    }

    private func configureLabel() {
        titleLabel?.textColor = .white
        titleLabel?.textAlignment = .center
        titleLabel?.numberOfLines = 0
        titleLabel?.font = .preferredFont(forTextStyle: .body)
        titleLabel?.adjustsFontForContentSizeCategory = true
    }

    private func setMessageAnimated(_ message: String?) {
        if let message {
            showAnimated(message)
        } else {
            hideMessageAnimated()
        }
    }

    private func showAnimated(_ message: String) {
        configuration?.attributedTitle = AttributedString(message, attributes: titleAttributes)
        configuration?.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)

        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }

    @objc private func hideMessageAnimated() {
        UIView.animate(withDuration: 0.25) {
            self.alpha = 0
        } completion: { isCompleted in
            if isCompleted {
                self.hideMessage()
            }
        }
    }

    private func hideMessage() {
        alpha = 0
        configuration?.attributedTitle = nil
        configuration?.contentInsets = .zero
        onHide?()
    }
}
