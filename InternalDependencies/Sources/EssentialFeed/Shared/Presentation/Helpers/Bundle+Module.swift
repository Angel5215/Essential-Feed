//
// Bundle+Module.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import Foundation

@_spi(Bundle) public enum EssentialFeed {
    public static var bundle: Bundle {
        .module
    }
}
