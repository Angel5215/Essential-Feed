//
// RemoteFeedLoaderTests.swift
// Copyright © 2025 Ángel Vázquez. All rights reserved.
//

import EssentialFeed
import Foundation
import Testing

struct RemoteFeedLoaderTests {
    private let leakHelper = MemoryLeakHelper()

    @Test
    func `init does not request data from URL`() {
        let (_, client) = makeSUT()

        #expect(client.requestedURLs.isEmpty)
    }

    @Test
    func `load requests data from URL`() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)

        sut.load { _ in }

        #expect(client.requestedURLs == [url])
    }

    @Test
    func `load twice requests data from URL twice`() {
        let url = URL(string: "https://a-given-url")!
        let (sut, client) = makeSUT(url: url)

        sut.load { _ in }
        sut.load { _ in }

        #expect(client.requestedURLs == [url, url])
    }

    @Test
    func `load delivers error on client error`() async {
        let (sut, client) = makeSUT()

        await expect(sut, toCompleteWith: failure(.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }

    @Test
    func `load delivers error on non-200 HTTP response`() async {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 300, 400, 500]

        for (index, code) in samples.enumerated() {
            await expect(sut, toCompleteWith: failure(.invalidData), when: {
                let json = makeItemsJSON([])
                client.complete(withStatusCode: code, data: json, at: index)
            })
        }
    }

    @Test
    func `load delivers error on 200 HTTP response with invalid JSON`() async {
        let (sut, client) = makeSUT()

        await expect(sut, toCompleteWith: failure(.invalidData), when: {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }

    @Test
    func `load delivers no items on 200 HTTP response with empty JSON list`() async {
        let (sut, client) = makeSUT()

        await expect(sut, toCompleteWith: .success([]), when: {
            let emptyListJSON = makeItemsJSON([])
            client.complete(withStatusCode: 200, data: emptyListJSON)
        })
    }

    @Test
    func `load delivers items on 200 HTTP response with JSON items`() async {
        let (sut, client) = makeSUT()
        let item1 = makeItem(
            id: UUID(),
            imageURL: URL(string: "https://a-url.com")!,
        )

        let item2 = makeItem(
            id: UUID(),
            description: "a description",
            location: "a location",
            imageURL: URL(string: "https://another-url.com")!,
        )
        let items = [item1.model, item2.model]

        await expect(sut, toCompleteWith: .success(items), when: {
            let json = makeItemsJSON([item1.json, item2.json])
            client.complete(withStatusCode: 200, data: json)
        })
    }

    @Test
    func `load does not deliver result after SUT instance has been deallocated`() {
        let url = URL(string: "https://any-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)

        var capturedResults = [RemoteFeedLoader.Result]()
        sut?.load { capturedResults.append($0) }

        sut = nil
        client.complete(withStatusCode: 200, data: makeItemsJSON([]))

        #expect(capturedResults.isEmpty)
    }

    // MARK: - Helpers

    private func makeSUT(
        url: URL = URL(string: "https://a-url.com")!,
        sourceLocation: SourceLocation = #_sourceLocation,
    ) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        leakHelper.track(sut, sourceLocation: sourceLocation)
        leakHelper.track(client, sourceLocation: sourceLocation)
        return (sut, client)
    }

    private func makeItem(
        id: UUID,
        description: String? = nil,
        location: String? = nil,
        imageURL: URL,
    ) -> (model: FeedItem, json: [String: Any]) {
        let item = FeedItem(id: id, description: description, location: location, imageURL: imageURL)
        let json = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString,
        ].compactMapValues(\.self)

        return (item, json)
    }

    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }

    private func expect(
        _ sut: RemoteFeedLoader,
        toCompleteWith expectedResult: RemoteFeedLoader.Result,
        when action: () -> Void,
        sourceLocation: SourceLocation = #_sourceLocation,
    ) async {
        await withCheckedContinuation { continuation in
            sut.load { receivedResult in
                switch (receivedResult, expectedResult) {
                case let (.success(receivedItems), .success(expectedItems)):
                    #expect(receivedItems == expectedItems, sourceLocation: sourceLocation)
                case let (.failure(receivedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
                    #expect(receivedError == expectedError, sourceLocation: sourceLocation)
                default:
                    Issue.record("Expected result \(expectedResult), got \(receivedResult) instead", sourceLocation: sourceLocation)
                }
                continuation.resume()
            }
            action()
        }
    }

    private func failure(_ error: RemoteFeedLoader.Error) -> LoadFeedResult {
        .failure(error)
    }

    private final class HTTPClientSpy: HTTPClient {
        private(set) var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        var requestedURLs: [URL] { messages.map(\.url) }

        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }

        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }

        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil,
            )!

            messages[index].completion(.success(data, response))
        }
    }
}
