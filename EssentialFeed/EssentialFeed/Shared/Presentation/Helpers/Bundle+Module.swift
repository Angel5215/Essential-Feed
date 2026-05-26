//
// Bundle+Module.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import Foundation

@_spi(Bundle) public extension Bundle {
    static var essentialFeed: Bundle {
        Bundle(for: Marker.self)
    }
}

private final class Marker {}
