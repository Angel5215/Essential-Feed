//
// FeedEndpointTests.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import EssentialFeed
import Foundation
import Testing

struct FeedEndpointTests {
    @Test
    func `Feed endpoint URL has expected value`() {
        let baseURL = URL(string: "https://base-url.com")!

        let received = FeedEndpoint.get(after: .none).url(baseURL: baseURL)

        #expect(received.scheme == "https", "Scheme")
        #expect(received.host(percentEncoded: true) == "base-url.com", "Host")
        #expect(received.path(percentEncoded: true) == "/v1/feed", "Path")
        #expect(received.query(percentEncoded: true) == "limit=10", "Query")
    }

    @Test
    func `Feed endpoint URL after given image`() throws {
        let image = uniqueImage()
        let baseURL = URL(string: "https://base-url.com")!

        let received = FeedEndpoint.get(after: image).url(baseURL: baseURL)

        #expect(received.scheme == "https")
        #expect(received.host(percentEncoded: true) == "base-url.com")
        #expect(received.path(percentEncoded: true) == "/v1/feed")
        try #expect(#require(received.query(percentEncoded: true)?.contains("limit=10")), "Limit query param")
        try #expect(#require(received.query(percentEncoded: true)?.contains("after_id=\(image.id)")), "After ID query param")
    }
}
