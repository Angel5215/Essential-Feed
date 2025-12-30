//
// ErrorView.swift
// Copyright © 2025 Ángel Vázquez. All rights reserved.
//

import UIKit

public final class ErrorView: UIView {
    @IBOutlet private var label: UILabel!

    public var message: String? {
        get { label.text }
        set { label.text = newValue }
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
        label.text = nil
    }
}
