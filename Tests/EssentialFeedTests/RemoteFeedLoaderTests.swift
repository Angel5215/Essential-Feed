//
// RemoteFeedLoaderTests.swift
// Copyright © 2025 Ángel Vázquez. All rights reserved.
//

@testable import EssentialFeed
import Foundation
import Testing

class RemoteFeedLoader {
    func load() {
        HTTPClient.shared.get(from: URL(string: "https://a-url.com")!)
    }
}

class HTTPClient {
    nonisolated(unsafe) static var shared = HTTPClient()

    func get(from url: URL) {}
}

class HTTPClientSpy: HTTPClient {
    var requestedURL: URL?

    override func get(from url: URL) {
        self.requestedURL = url
    }
}

struct RemoteFeedLoaderTests {
    @Test func `init does not request data from URL`() {
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        _ = RemoteFeedLoader()

        #expect(client.requestedURL == nil)
    }

    @Test func `load requests data from URL`() {
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        let sut = RemoteFeedLoader()

        sut.load()

        #expect(client.requestedURL != nil)
    }
}
