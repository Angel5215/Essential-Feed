//
// UIImage+TestHelpers.swift
// Copyright © 2025 Ángel Vázquez. All rights reserved.
//

import UIKit

extension UIImage {
    static func make(withColor color: UIColor) -> UIImage {
        let size = CGSize(width: 1, height: 1)
        let rect = CGRect(origin: .zero, size: size)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            color.setFill()
            context.fill(rect)
        }
    }
}
