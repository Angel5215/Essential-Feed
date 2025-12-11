//
// RemoteFeedLoaderTests.swift
// Copyright © 2025 Ángel Vázquez. All rights reserved.
//

@testable import EssentialFeed
import Foundation
import Testing

class RemoteFeedLoader {
    let url: URL
    let client: HTTPClient

    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    func load() {
        client.get(from: url)
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
        let url = URL(string: "https://a-given-url.com")!
        let client = HTTPClientSpy()
        _ = RemoteFeedLoader(url: url, client: client)

        #expect(client.requestedURL == nil)
    }

    @Test func `load requests data from URL`() {
        let url = URL(string: "https://a-given-url.com")!
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)

        sut.load()

        #expect(client.requestedURL == url)
    }
}
