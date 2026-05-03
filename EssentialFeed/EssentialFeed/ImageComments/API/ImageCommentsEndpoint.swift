//
// ImageCommentsEndpoint.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import Foundation

public enum ImageCommentsEndpoint {
    case get(UUID)

    public func url(baseURL: URL) -> URL {
        switch self {
        case let .get(imageID):
            baseURL.appending(path: "/v1/image/\(imageID)/comments")
        }
    }
}
