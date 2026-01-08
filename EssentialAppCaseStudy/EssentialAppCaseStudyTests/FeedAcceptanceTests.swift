//
// FeedAcceptanceTests.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

@testable import EssentialAppCaseStudy
import EssentialFeed
import EssentialFeedMobile
import XCTest

final class FeedAcceptanceTests: XCTestCase {
    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() throws {
        let feed = try launch(httpClient: .online(response(for:)), store: .empty)

        XCTAssertEqual(feed.numberOfRenderedFeedImageViews(), 2)
        XCTAssertEqual(feed.renderedFeedImageData(at: 0), makeImageData())
        XCTAssertEqual(feed.renderedFeedImageData(at: 1), makeImageData())
    }

    func test_onLaunch_displaysCachedRemoteFeedWhenCustomerHasNoConnectivity() throws {
        let sharedStore = InMemoryFeedStore.empty
        let onlineFeed = try launch(httpClient: .online(response(for:)), store: sharedStore)

        onlineFeed.simulateFeedImageViewVisible(at: 0)
        onlineFeed.simulateFeedImageViewVisible(at: 1)

        let offlineFeed = try launch(httpClient: .offline, store: sharedStore)

        XCTAssertEqual(offlineFeed.numberOfRenderedFeedImageViews(), 2)
        XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 0), makeImageData())
        XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 1), makeImageData())
    }

    func test_onLaunch_displaysEmptyFeedWhenCustomerHasNoConnectivityAndNoCache() throws {
        let feed = try launch(httpClient: .offline, store: .empty)

        XCTAssertEqual(feed.numberOfRenderedFeedImageViews(), 0)
    }

    // MARK: - Helpers

    private func launch(httpClient: HTTPClientStub, store: InMemoryFeedStore) throws -> FeedViewController {
        let sut = SceneDelegate(httpClient: httpClient, store: store)
        sut.window = try UIWindowSpy.make()
        sut.configureWindow()

        let nav = sut.window?.rootViewController as? UINavigationController
        let feed = nav?.topViewController as! FeedViewController
        feed.simulateAppearance()

        return feed
    }

    private final class HTTPClientStub: HTTPClient {
        private let stub: (URL) -> HTTPClient.Result

        init(stub: @escaping (URL) -> HTTPClient.Result) {
            self.stub = stub
        }

        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> any HTTPClientTask {
            completion(stub(url))
            return Task()
        }

        // MARK: - Helpers

        static var offline: HTTPClientStub {
            HTTPClientStub { _ in .failure(NSError(domain: "offline", code: 0)) }
        }

        static func online(_ stub: @escaping (URL) -> (Data, HTTPURLResponse)) -> HTTPClientStub {
            HTTPClientStub { .success(stub($0)) }
        }

        private final class Task: HTTPClientTask {
            func cancel() {}
        }
    }

    private final class InMemoryFeedStore: FeedStore, FeedImageDataStore {
        private var feedCache: CachedFeed?
        private var feedImageDataCache = [URL: Data]()

        // MARK: - FeedStore

        func deleteCachedFeed(completion: @escaping FeedStore.DeletionCompletion) {
            feedCache = nil
            completion(.success(()))
        }

        func insert(_ feed: [EssentialFeed.LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
            feedCache = CachedFeed(feed: feed, timestamp: timestamp)
            completion(.success(()))
        }

        func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
            completion(.success(feedCache))
        }

        // MARK: - FeedImageDataStore

        func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
            completion(.success(feedImageDataCache[url]))
        }

        func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
            feedImageDataCache[url] = data
            completion(.success(()))
        }

        // MARK: - Helpers

        static var empty: InMemoryFeedStore {
            InMemoryFeedStore()
        }
    }

    private func response(for url: URL) -> (Data, HTTPURLResponse) {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (makeData(for: url), response)
    }

    private func makeData(for url: URL) -> Data {
        switch url.absoluteString {
        case "https://image.com":
            makeImageData()
        default:
            makeFeedData()
        }
    }

    private func makeImageData() -> Data {
        UIImage.make(withColor: .red).pngData()!
    }

    private func makeFeedData() -> Data {
        try! JSONSerialization.data(
            withJSONObject: [
                "items": [
                    ["id": UUID().uuidString, "image": "https://image.com"],
                    ["id": UUID().uuidString, "image": "https://image.com"],
                ]
            ]
        )
    }

    private final class UIWindowSpy: UIWindow {
        static func make(file: StaticString = #filePath, line: UInt = #line) throws -> UIWindowSpy {
            let dummyScene = try XCTUnwrap((UIWindowScene.self as NSObject.Type).init() as? UIWindowScene)
            return UIWindowSpy(windowScene: dummyScene)
        }

        override func makeKeyAndVisible() {}
    }
}
