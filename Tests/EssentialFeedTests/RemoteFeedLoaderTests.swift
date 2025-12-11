//
// RemoteFeedLoaderTests.swift
// Copyright © 2025 Ángel Vázquez. All rights reserved.
//

@testable import EssentialFeed
import Foundation
import Testing

class RemoteFeedLoader {
    func load() {
        HTTPClient.shared.requestedURL = URL(string: "https://a-url.com")
    }
}

@preconcurrency class HTTPClient {
    static let shared = HTTPClient()

    private init() {}

    var requestedURL: URL?
}

struct RemoteFeedLoaderTests {
    @Test func `init does not request data from URL`() {
        let client = HTTPClient.shared
        _ = RemoteFeedLoader()

        #expect(client.requestedURL == nil)
    }

    @Test func `load requests data from URL`() {
        let client = HTTPClient.shared
        let sut = RemoteFeedLoader()

        sut.load()

        #expect(client.requestedURL != nil)
    }
}
