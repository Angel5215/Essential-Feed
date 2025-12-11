//
// RemoteFeedLoaderTests.swift
// Copyright © 2025 Ángel Vázquez. All rights reserved.
//

@testable import EssentialFeed
import Foundation
import Testing

class RemoteFeedLoader {
    let client: HTTPClient

    init(client: HTTPClient) {
        self.client = client
    }

    func load() {
        client.get(from: URL(string: "https://a-url.com")!)
    }
}

protocol HTTPClient {
    func get(from url: URL)
}

class HTTPClientSpy: HTTPClient {
    var requestedURL: URL?

    func get(from url: URL) {
        requestedURL = url
    }
}

struct RemoteFeedLoaderTests {
    @Test func `init does not request data from URL`() {
        let client = HTTPClientSpy()
        _ = RemoteFeedLoader(client: client)

        #expect(client.requestedURL == nil)
    }

    @Test func `load requests data from URL`() {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client)

        sut.load()

        #expect(client.requestedURL != nil)
    }
}
