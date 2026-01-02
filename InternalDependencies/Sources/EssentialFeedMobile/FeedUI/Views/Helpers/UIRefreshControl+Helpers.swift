//
// UIRefreshControl+Helpers.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import UIKit

extension UIRefreshControl {
    func update(isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}
