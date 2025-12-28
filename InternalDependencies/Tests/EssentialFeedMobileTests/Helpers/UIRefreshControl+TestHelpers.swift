//
// UIRefreshControl+TestHelpers.swift
// Copyright © 2025 Ángel Vázquez. All rights reserved.
//

import UIKit

extension UIRefreshControl {
    func simulatePullToRefresh() {
        simulate(event: .valueChanged)
    }
}
