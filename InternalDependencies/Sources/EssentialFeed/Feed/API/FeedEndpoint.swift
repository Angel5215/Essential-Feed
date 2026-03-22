//
// FeedEndpoint.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import Foundation

public enum FeedEndpoint {
    case get

    public func url(baseURL: URL) -> URL {
        switch self {
        case .get:
            baseURL.appending(path: "/v1/feed")
        }
    }
}
