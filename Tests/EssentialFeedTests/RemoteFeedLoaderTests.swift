//
// RemoteFeedLoaderTests.swift
// Copyright © 2025 Ángel Vázquez. All rights reserved.
//

@testable import EssentialFeed
import Foundation
import Testing

class RemoteFeedLoader {}

class HTTPClient {
    var requestedURL: URL?
}

struct RemoteFeedLoaderTests {
    @Test func `init does not request data from URL`() {
        let client = HTTPClient()
        _ = RemoteFeedLoader()

        #expect(client.requestedURL == nil)
    }
}
