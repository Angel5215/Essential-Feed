//
// URLSessionHTTPClientTests.swift
// Copyright © 2025 Ángel Vázquez. All rights reserved.
//

import Foundation
import Testing

class URLSessionHTTPClient {
    private let session: URLSession

    init(session: URLSession) {
        self.session = session
    }

    func get(from url: URL) {
        session.dataTask(with: url) { _, _, _ in }
    }
}

struct URLSessionHTTPClientTests {
    @Test func `get from URL creates data task with URL`() {
        let url = URL(string: "https://any-url.com")!
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)

        sut.get(from: url)

        #expect(session.receivedURLs == [url])
    }

    // MARK: - Helpers

    private class URLSessionSpy: URLSession {
        var receivedURLs = [URL]()

        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTask {
            receivedURLs.append(url)
            return FakeURLSessionDataTask()
        }
    }

    private class FakeURLSessionDataTask: URLSessionDataTask {}
}
