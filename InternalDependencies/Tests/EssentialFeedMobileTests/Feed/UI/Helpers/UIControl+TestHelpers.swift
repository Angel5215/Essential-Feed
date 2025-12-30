//
// UIControl+TestHelpers.swift
// Copyright © 2025 Ángel Vázquez. All rights reserved.
//

import UIKit

extension UIControl {
    func simulate(event: UIControl.Event) {
        for target in allTargets {
            actions(forTarget: target, forControlEvent: event)?.forEach { action in
                (target as NSObject).perform(Selector(action))
            }
        }
    }
}
