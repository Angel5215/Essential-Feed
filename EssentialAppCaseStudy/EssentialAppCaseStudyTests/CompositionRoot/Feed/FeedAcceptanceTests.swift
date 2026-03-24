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
        XCTAssertEqual(feed.renderedFeedImageData(at: 0), makeImageData0())
        XCTAssertEqual(feed.renderedFeedImageData(at: 1), makeImageData1())
        XCTAssertTrue(feed.canLoadMoreFeed)

        feed.simulateLoadMoreFeedAction()
        XCTAssertEqual(feed.numberOfRenderedFeedImageViews(), 3)
        XCTAssertEqual(feed.renderedFeedImageData(at: 0), makeImageData0())
        XCTAssertEqual(feed.renderedFeedImageData(at: 1), makeImageData1())
        XCTAssertEqual(feed.renderedFeedImageData(at: 2), makeImageData2())
        XCTAssertTrue(feed.canLoadMoreFeed)

        feed.simulateLoadMoreFeedAction()
        XCTAssertEqual(feed.numberOfRenderedFeedImageViews(), 3)
        XCTAssertEqual(feed.renderedFeedImageData(at: 0), makeImageData0())
        XCTAssertEqual(feed.renderedFeedImageData(at: 1), makeImageData1())
        XCTAssertEqual(feed.renderedFeedImageData(at: 2), makeImageData2())
        XCTAssertFalse(feed.canLoadMoreFeed)
    }

    func test_onLaunch_displaysCachedRemoteFeedWhenCustomerHasNoConnectivity() throws {
        let sharedStore = InMemoryFeedStore.empty
        let onlineFeed = try launch(httpClient: .online(response(for:)), store: sharedStore)

        onlineFeed.simulateFeedImageViewVisible(at: 0)
        onlineFeed.simulateFeedImageViewVisible(at: 1)

        let offlineFeed = try launch(httpClient: .offline, store: sharedStore)

        XCTAssertEqual(offlineFeed.numberOfRenderedFeedImageViews(), 2)
        XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 0), makeImageData0())
        XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 1), makeImageData1())
    }

    func test_onLaunch_displaysEmptyFeedWhenCustomerHasNoConnectivityAndNoCache() throws {
        let feed = try launch(httpClient: .offline, store: .empty)

        XCTAssertEqual(feed.numberOfRenderedFeedImageViews(), 0)
    }

    func test_onEnteringBackground_deletesExpiredFeedCache() {
        let store = InMemoryFeedStore.withExpiredFeedCache

        enterBackground(with: store)

        XCTAssertNil(store.feedCache, "Expected to delete expired cache")
    }

    func test_onEnteringBackground_keepsNonExpiredFeedCache() {
        let store = InMemoryFeedStore.withNonExpiredFeedCache

        enterBackground(with: store)

        XCTAssertNotNil(store.feedCache, "Expected to keep non-expired cache")
    }

    func test_onFeedImageSelection_displaysComments() throws {
        let comments = try showCommentsForFirstImage()

        XCTAssertEqual(comments.numberOfRenderedComments(), 1)
        XCTAssertEqual(comments.commentMessage(at: 0), makeCommentMessage())
    }

    // MARK: - Helpers

    private func launch(httpClient: HTTPClientStub, store: InMemoryFeedStore) throws -> ListViewController {
        let sut = SceneDelegate(httpClient: httpClient, store: store)
        sut.window = try UIWindowSpy.make()
        sut.configureWindow()

        let navigationController = sut.window?.rootViewController as? UINavigationController
        let feed = navigationController?.topViewController as! ListViewController
        feed.simulateAppearance()

        return feed
    }

    private func enterBackground(with store: InMemoryFeedStore) {
        let sut = SceneDelegate(httpClient: HTTPClientStub.offline, store: store)
        sut.sceneWillResignActive(UIApplication.shared.connectedScenes.first!)
    }

    private func showCommentsForFirstImage() throws -> ListViewController {
        let feed = try launch(httpClient: .online(response(for:)), store: .empty)

        feed.simulateTapOnFeedImage(at: 0)
        RunLoop.current.run(until: Date())

        let navigationController = feed.navigationController
        let commentsViewController = navigationController?.topViewController as! ListViewController
        commentsViewController.simulateAppearance()
        return commentsViewController
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
        private(set) var feedCache: CachedFeed?
        private var feedImageDataCache = [URL: Data]()

        init(feedCache: CachedFeed? = nil) {
            self.feedCache = feedCache
        }

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

        static var withExpiredFeedCache: InMemoryFeedStore {
            InMemoryFeedStore(feedCache: CachedFeed(feed: [], timestamp: Date.distantPast))
        }

        static var withNonExpiredFeedCache: InMemoryFeedStore {
            InMemoryFeedStore(feedCache: CachedFeed(feed: [], timestamp: Date()))
        }
    }

    private func response(for url: URL) -> (Data, HTTPURLResponse) {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (makeData(for: url), response)
    }

    private func makeData(for url: URL) -> Data {
        switch url.path(percentEncoded: true) {
        case "/image-0":
            makeImageData0()
        case "/image-1":
            makeImageData1()
        case "/image-2":
            makeImageData2()
        case "/essential-feed/v1/feed" where url.query(percentEncoded: true)?.contains("after_id") == false:
            makeFirstFeedPageData()
        case "/essential-feed/v1/feed" where url.query(percentEncoded: true)?.contains("after_id=A28F5FE3-27A7-44E9-8DF5-53742D0E4A5A") == true:
            makeSecondFeedPageData()
        case "/essential-feed/v1/feed" where url.query(percentEncoded: true)?.contains("after_id=166FCDD7-C9F4-420A-B2D6-CE2EAFA3D82F") == true:
            makeLastEmptyFeedPageData()
        case "/essential-feed/v1/image/2AB2AE66-A4B7-4A16-B374-51BBAC8DB086/comments":
            makeCommentsData()
        default:
            Data()
        }
    }

    private func makeImageData0() -> Data {
        UIImage.make(withColor: .red).pngData()!
    }

    private func makeImageData1() -> Data {
        UIImage.make(withColor: .green).pngData()!
    }

    private func makeImageData2() -> Data {
        UIImage.make(withColor: .blue).pngData()!
    }

    private func makeFirstFeedPageData() -> Data {
        try! JSONSerialization.data(
            withJSONObject: [
                "items": [
                    [
                        "id": "2AB2AE66-A4B7-4A16-B374-51BBAC8DB086",
                        "image": "http://feed.com/image-0",
                    ],
                    [
                        "id": "A28F5FE3-27A7-44E9-8DF5-53742D0E4A5A",
                        "image": "http://feed.com/image-1",
                    ],
                ]
            ]
        )
    }

    private func makeSecondFeedPageData() -> Data {
        try! JSONSerialization.data(
            withJSONObject: [
                "items": [
                    [
                        "id": "166FCDD7-C9F4-420A-B2D6-CE2EAFA3D82F",
                        "image": "http://feed.com/image-2",
                    ]
                ]
            ]
        )
    }

    private func makeLastEmptyFeedPageData() -> Data {
        try! JSONSerialization.data(
            withJSONObject: [
                "items": []
            ]
        )
    }

    private func makeCommentsData() -> Data {
        try! JSONSerialization.data(
            withJSONObject: [
                "items": [
                    [
                        "id": UUID().uuidString,
                        "message": makeCommentMessage(),
                        "created_at": "2020-05-20T11:24:59+0000",
                        "author": [
                            "username": "a username"
                        ],
                    ]
                ]
            ]
        )
    }

    private func makeCommentMessage() -> String {
        "a message"
    }

    private final class UIWindowSpy: UIWindow {
        static func make(file: StaticString = #filePath, line: UInt = #line) throws -> UIWindowSpy {
            let dummyScene = try XCTUnwrap((UIWindowScene.self as NSObject.Type).init() as? UIWindowScene)
            return UIWindowSpy(windowScene: dummyScene)
        }

        override func makeKeyAndVisible() {}
    }
}
