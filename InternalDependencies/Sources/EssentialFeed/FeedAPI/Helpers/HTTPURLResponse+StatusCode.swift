//
// HTTPURLResponse+StatusCode.swift
// Copyright © 2025 Ángel Vázquez. All rights reserved.
//

import Foundation

extension HTTPURLResponse {
    private enum StatusCode {
        static let success = 200
    }

    var isOK: Bool {
        statusCode == StatusCode.success
    }
}
