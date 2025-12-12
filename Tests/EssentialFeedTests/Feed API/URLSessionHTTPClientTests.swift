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
        session.dataTask(with: url) { _, _, _ in }.resume()
    }
}

struct URLSessionHTTPClientTests {
    @Test func `get from URL resumes data task with URL`() {
        let url = URL(string: "https://any-url.com")!
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, task: task)
        let sut = URLSessionHTTPClient(session: session)

        sut.get(from: url)

        #expect(task.resumeCallCount == 1)
    }

    // MARK: - Helpers

    private class URLSessionSpy: URLSession {
        private var stubs = [URL: URLSessionDataTask]()

        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTask {
            stubs[url] ?? FakeURLSessionDataTask()
        }

        func stub(url: URL, task: URLSessionDataTask) {
            stubs[url] = task
        }
    }

    private class FakeURLSessionDataTask: URLSessionDataTask {
        override func resume() {}
    }

    private class URLSessionDataTaskSpy: URLSessionDataTask {
        private(set) var resumeCallCount = 0

        override func resume() {
            resumeCallCount += 1
        }
    }
}
