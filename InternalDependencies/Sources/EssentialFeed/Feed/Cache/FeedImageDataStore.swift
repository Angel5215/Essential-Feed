//
// FeedImageDataStore.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import Foundation

public protocol FeedImageDataStore {
    func retrieve(dataForURL url: URL) throws -> Data?
    func insert(_ data: Data, for url: URL) throws
}
