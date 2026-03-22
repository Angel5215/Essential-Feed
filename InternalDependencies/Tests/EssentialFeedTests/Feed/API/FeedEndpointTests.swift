//
// FeedEndpointTests.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import EssentialFeed
import Foundation
import Testing

struct FeedEndpointTests {
    @Test
    func `feed endpoint URL has expected value`() {
        let baseURL = URL(string: "https://base-url.com")!

        let received = FeedEndpoint.get.url(baseURL: baseURL)
        let expected = URL(string: "https://base-url.com/v1/feed")!

        #expect(received == expected)
    }
}
