//
// UIView+Shimmering.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import UIKit

extension UIView {
    public var isShimmering: Bool {
        set {
            if newValue {
                startShimmering()
            } else {
                stopShimmering()
            }
        }

        get {
            layer.mask is ShimmeringLayer
        }
    }

    private func startShimmering() {
        layer.mask = ShimmeringLayer(size: bounds.size)
    }

    private func stopShimmering() {
        layer.mask = nil
    }

    private final class ShimmeringLayer: CAGradientLayer {
        override nonisolated init() {
            super.init()
        }

        override nonisolated init(layer: Any) {
            super.init(layer: layer)
        }

        required nonisolated init?(coder: NSCoder) {
            super.init(coder: coder)
        }

        private var observer: Any?

        convenience init(size: CGSize) {
            self.init()

            let white = UIColor.white.cgColor
            let alpha = UIColor.white.withAlphaComponent(0.75).cgColor

            colors = [alpha, white, alpha]
            startPoint = CGPoint(x: 0.0, y: 0.4)
            endPoint = CGPoint(x: 1.0, y: 0.6)
            locations = [0.4, 0.5, 0.6]
            frame = CGRect(x: -size.width, y: 0, width: size.width * 3, height: size.height)

            let animation = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.locations))
            animation.fromValue = [0.0, 0.1, 0.2]
            animation.toValue = [0.8, 0.9, 1.0]
            animation.duration = 1.25
            animation.repeatCount = .infinity
            add(animation, forKey: "shimmer")

            self.observer = NotificationCenter.default.addObserver(of: UIApplication.shared, for: .willEnterForeground) { [weak self] _ in
                self?.add(animation, forKey: "shimmer")
            }
        }
    }
}
