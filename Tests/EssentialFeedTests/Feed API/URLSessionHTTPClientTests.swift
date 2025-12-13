//
// URLSessionHTTPClientTests.swift
// Copyright © 2025 Ángel Vázquez. All rights reserved.
//

import EssentialFeed
import Foundation
import Testing

protocol HTTPSession {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask
}

protocol HTTPSessionTask {
    func resume()
}

final class URLSessionHTTPClient {
    private let session: HTTPSession

    init(session: HTTPSession) {
        self.session = session
    }

    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error {
                completion(.failure(error))
            }
        }.resume()
    }
}

struct URLSessionHTTPClientTests {
    @Test
    func `get from URL resumes data task with URL`() {
        let url = URL(string: "https://any-url.com")!
        let session = HTTPSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, task: task)
        let sut = URLSessionHTTPClient(session: session)

        sut.get(from: url) { _ in }

        #expect(task.resumeCallCount == 1)
    }

    @Test
    func `get from URL fails on request error`() async {
        let url = URL(string: "https://any-url.com")!
        let session = HTTPSessionSpy()
        let error = NSError(domain: "any error", code: 1)
        session.stub(url: url, error: error)
        let sut = URLSessionHTTPClient(session: session)

        await confirmation { confirm in
            sut.get(from: url) { result in
                switch result {
                case let .failure(receivedError as NSError):
                    #expect(receivedError.domain == error.domain)
                    #expect(receivedError.code == error.code)
                default:
                    Issue.record("Expected failure with error \(error), got \(result) instead.")
                }
                confirm()
            }
        }
    }

    // MARK: - Helpers

    private class HTTPSessionSpy: HTTPSession {
        private var stubs = [URL: Stub]()

        func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> HTTPSessionTask {
            guard let stub = stubs[url] else {
                fatalError("Could not find stub for \(url)")
            }
            completionHandler(nil, nil, stub.error)
            return stub.task
        }

        // MARK: - Helpers

        func stub(url: URL, task: HTTPSessionTask = FakeURLSessionDataTask(), error: Error? = nil) {
            stubs[url] = Stub(task: task, error: error)
        }

        private struct Stub {
            let task: HTTPSessionTask
            let error: Error?
        }
    }

    private class FakeURLSessionDataTask: HTTPSessionTask {
        func resume() {}
    }

    private class URLSessionDataTaskSpy: HTTPSessionTask {
        private(set) var resumeCallCount = 0

        func resume() {
            resumeCallCount += 1
        }
    }
}
