//
// UIButton+TestHelpers.swift
// Copyright © 2025 Ángel Vázquez. All rights reserved.
//

import UIKit

extension UIButton {
    func simulateTap() {
        for target in allTargets {
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach { action in
                (target as NSObject).perform(Selector(action))
            }
        }
    }
}
