//
// ErrorView.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import UIKit

public final class ErrorView: UIButton {
    public var message: String? {
        get { isVisible ? title(for: .normal) : nil }
        set { setMessageAnimated(newValue) }
    }

    public var onHide: (() -> Void)?

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

    override public func awakeFromNib() {
        super.awakeFromNib()
    }

    // MARK: - Private methods

    private func configure() {
        backgroundColor = .errorBackground
        addTarget(self, action: #selector(hideMessageAnimated), for: .touchUpInside)
        configureLabel()
        hideMessage()
    }

    private func configureLabel() {
        titleLabel?.textColor = .white
        titleLabel?.textAlignment = .center
        titleLabel?.numberOfLines = 0
        titleLabel?.font = .systemFont(ofSize: 17)
    }

    private func setMessageAnimated(_ message: String?) {
        if let message {
            showAnimated(message)
        } else {
            hideMessageAnimated()
        }
    }

    private func showAnimated(_ message: String) {
        setTitle(message, for: .normal)
        contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

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
        setTitle(nil, for: .normal)
        alpha = 0
        contentEdgeInsets = UIEdgeInsets(top: -2.5, left: 0, bottom: -2.5, right: 0)
        onHide?()
    }
}
