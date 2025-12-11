//
// RemoteFeedLoaderTests.swift
// Copyright © 2025 Ángel Vázquez. All rights reserved.
//

import EssentialFeed
import Foundation
import Testing

struct RemoteFeedLoaderTests {
    @Test func `init does not request data from URL`() {
        let (_, client) = makeSUT()

        #expect(client.requestedURLs.isEmpty)
    }

    @Test func `load requests data from URL`() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)

        sut.load()

        #expect(client.requestedURLs == [url])
    }

    @Test func `load twice requests data from URL twice`() {
        let url = URL(string: "https://a-given-url")!
        let (sut, client) = makeSUT(url: url)

        sut.load()
        sut.load()

        #expect(client.requestedURLs == [url, url])
    }

    @Test func `load delivers error on client error`() {
        let (sut, client) = makeSUT()

        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load { capturedErrors.append($0) }

        let clientError = NSError(domain: "Test", code: 0)
        client.complete(with: clientError)

        #expect(capturedErrors == [.connectivity])
    }

    // MARK: - Helpers

    private func makeSUT(
        url: URL = URL(string: "https://a-url.com")!,
    ) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }

    private class HTTPClientSpy: HTTPClient {
        private(set) var requestedURLs = [URL]()
        var completions = [(Error) -> Void]()
        var error: Error?

        func get(from url: URL, completion: @escaping (Error) -> Void) {
            if let error {
                completion(error)
            }
            completions.append(completion)
            requestedURLs.append(url)
        }

        func complete(with error: Error, at index: Int = 0) {
            completions[index](error)
        }
    }
}
