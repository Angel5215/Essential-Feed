//
// HTTPClient.swift
// Copyright © 2025 Ángel Vázquez. All rights reserved.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    /// The `completion` handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate thread, if needed.
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
