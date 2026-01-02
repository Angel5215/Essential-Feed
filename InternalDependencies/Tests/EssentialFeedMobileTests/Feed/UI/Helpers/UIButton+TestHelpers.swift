//
// UIButton+TestHelpers.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import UIKit

extension UIButton {
    func simulateTap() {
        simulate(event: .touchUpInside)
    }
}
