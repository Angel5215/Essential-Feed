//
// Bundle+Module.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import Foundation

extension Bundle {
    static var essentialFeedMobile: Bundle {
        Bundle(for: Marker.self)
    }
}

private final class Marker {}
