//
// FeedImageDataMapper.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import Foundation

public enum FeedImageDataMapper {
    public static func map(_ data: Data, from response: HTTPURLResponse) throws(Error) -> Data {
        guard response.isOK, !data.isEmpty else {
            throw .invalidData
        }
        return data
    }

    // MARK: - Helpers

    public enum Error: Swift.Error {
        case invalidData
    }
}
