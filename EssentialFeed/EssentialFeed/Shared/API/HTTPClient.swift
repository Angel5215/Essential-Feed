//
// HTTPClient.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL) async throws -> (Data, HTTPURLResponse)
}
