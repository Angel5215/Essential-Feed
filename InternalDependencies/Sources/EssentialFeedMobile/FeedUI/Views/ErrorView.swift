//
// ErrorView.swift
// Copyright © 2025 Ángel Vázquez. All rights reserved.
//

import UIKit

public final class ErrorView: UIView {
    @IBOutlet private var label: UILabel!

    public var message: String? {
        get { isVisible ? label.text : nil }
        set { setMessageAnimated(newValue) }
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
        label.text = nil
        alpha = 0
    }

    private var isVisible: Bool {
        alpha > 0
    }

    private func setMessageAnimated(_ message: String?) {
        if let message {
            showAnimated(message)
        } else {
            hideMessageAnimated()
        }
    }

    private func showAnimated(_ message: String) {
        label.text = message

        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }

    @IBAction private func hideMessageAnimated() {
        UIView.animate(withDuration: 0.25) {
            self.alpha = 0
        } completion: { isCompleted in
            if isCompleted {
                self.label.text = nil
            }
        }
    }
}
