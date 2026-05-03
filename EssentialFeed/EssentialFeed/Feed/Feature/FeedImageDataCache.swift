//
// FeedImageDataCache.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import Foundation

public protocol FeedImageDataCache {
    func save(_ data: Data, for url: URL) throws
}
