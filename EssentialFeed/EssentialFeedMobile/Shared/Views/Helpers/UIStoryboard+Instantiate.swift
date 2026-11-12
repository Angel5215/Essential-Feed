//
// UIStoryboard+Instantiate.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import UIKit

public extension UIStoryboard {
    func instantiateInitialViewController<T: UIViewController>(as type: T.Type) -> T {
        guard let controller = instantiateInitialViewController() as? T else {
            fatalError("Initial view controller of storyboard is not a \(type)")
        }
        return controller
    }
}
