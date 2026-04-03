//
// FeedEndpointTests.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import EssentialFeed
import Foundation
import Testing

struct FeedEndpointTests {
    @Test
    func `Feed endpoint URL has expected value`() throws {
        let baseURL = try #require(URL(string: "https://base-url.com"))

        let received = FeedEndpoint.get(after: .none).url(baseURL: baseURL)

        let receivedHost = received.host(percentEncoded: true)
        let receivedPath = received.path(percentEncoded: true)
        let receivedQuery = received.query(percentEncoded: true)

        #expect(received.scheme == "https", "Scheme")
        #expect(receivedHost == "base-url.com", "Host")
        #expect(receivedPath == "/v1/feed", "Path")
        #expect(receivedQuery == "limit=10", "Query")
    }

    @Test
    func `Feed endpoint URL after given image`() throws {
        let image = uniqueImage()
        let baseURL = try #require(URL(string: "https://base-url.com"))

        let received = FeedEndpoint.get(after: image).url(baseURL: baseURL)

        let receivedHost = received.host(percentEncoded: true)
        let receivedPath = received.path(percentEncoded: true)
        let receivedQuery = received.query(percentEncoded: true)

        #expect(received.scheme == "https")
        #expect(receivedHost == "base-url.com")
        #expect(receivedPath == "/v1/feed")
        #expect(receivedQuery?.contains("limit=10") == true, "Limit query param")
        #expect(receivedQuery?.contains("after_id=\(image.id)") == true, "After ID query param")
    }
}
