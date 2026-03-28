//
// FeedImageDataLoader.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import Foundation

public protocol FeedImageDataLoader {
    func loadImageData(from url: URL) throws -> Data
}
