//
// UIViewController+Snapshot.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import UIKit

extension UIViewController {
    func snapshot(for configuration: SnapshotConfiguration) -> UIImage {
        SnapshotWindow(configuration: configuration, root: self).snapshot()
    }
}

struct SnapshotConfiguration {
    let size: CGSize
    let safeAreaInsets: UIEdgeInsets
    let layoutMargins: UIEdgeInsets
    let traitCollection: UITraitCollection

    static func iPhone(style: UIUserInterfaceStyle, contentSize: UIContentSizeCategory = .medium) -> SnapshotConfiguration {
        SnapshotConfiguration(
            size: CGSize(width: 402, height: 874),
            safeAreaInsets: UIEdgeInsets(top: 62, left: 0, bottom: 34, right: 0),
            layoutMargins: UIEdgeInsets(top: 62, left: 16, bottom: 34, right: 16),
            traitCollection: UITraitCollection(mutations: { traits in
                traits.forceTouchCapability = .unavailable
                traits.layoutDirection = .leftToRight
                traits.preferredContentSizeCategory = contentSize
                traits.userInterfaceIdiom = .phone
                traits.horizontalSizeClass = .compact
                traits.verticalSizeClass = .regular
                traits.displayScale = 3
                traits.displayGamut = .P3
                traits.userInterfaceStyle = style
            }),
        )
    }
}

private final class SnapshotWindow: UIWindow {
    private var configuration = SnapshotConfiguration.iPhone(style: .light)

    convenience init(configuration: SnapshotConfiguration, root: UIViewController) {
        let dummyScene = (UIWindowScene.self as NSObject.Type).init() as! UIWindowScene
        self.init(windowScene: dummyScene)
        self.frame = CGRect(origin: .zero, size: configuration.size)
        self.configuration = configuration
        self.layoutMargins = configuration.layoutMargins
        self.rootViewController = root
        self.isHidden = false
        root.view.layoutMargins = configuration.layoutMargins
    }

    override var safeAreaInsets: UIEdgeInsets {
        configuration.safeAreaInsets
    }

    override var traitCollection: UITraitCollection {
        configuration.traitCollection
    }

    func snapshot() -> UIImage {
        UIGraphicsImageRenderer(bounds: bounds, format: UIGraphicsImageRendererFormat(for: traitCollection)).image { action in
            layer.render(in: action.cgContext)
        }
    }
}
