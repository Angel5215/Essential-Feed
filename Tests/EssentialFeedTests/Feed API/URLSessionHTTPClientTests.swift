//
// URLSessionHTTPClientTests.swift
// Copyright © 2025 Ángel Vázquez. All rights reserved.
//

import EssentialFeed
import Foundation
import Testing

final class URLSessionHTTPClient: Sendable {
    private let session: URLSession

    init(session: URLSession) {
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
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, task: task)
        let sut = URLSessionHTTPClient(session: session)

        sut.get(from: url) { _ in }

        #expect(task.resumeCallCount == 1)
    }

    @Test
    func `get from URL fails on request error`() async {
        let url = URL(string: "https://any-url.com")!
        let session = URLSessionSpy()
        let error = NSError(domain: "any error", code: 1)
        session.stub(url: url, error: error)
        let sut = URLSessionHTTPClient(session: session)

        await withTaskTimeoutHandler(timeout: .seconds(1)) {
            _ = await withCheckedContinuation { continuation in
                sut.get(from: url) { result in
                    switch result {
                    case let .failure(receivedError as NSError):
                        #expect(receivedError.domain == error.domain)
                        #expect(receivedError.code == error.code)
                    default:
                        Issue.record("Expected failure with error \(error), got \(result) instead.")
                    }
                    continuation.resume(returning: ())
                }
            }
        } onTimeout: {
            Issue.record("Task did not complete in the allotted time.")
        }
    }

    // MARK: - Helpers

    private class URLSessionSpy: URLSession, @unchecked Sendable {
        private var stubs = [URL: Stub]()

        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTask {
            guard let stub = stubs[url] else {
                fatalError("Could not find stub for \(url)")
            }
            completionHandler(nil, nil, stub.error)
            return stub.task
        }

        // MARK: - Helpers

        func stub(url: URL, task: URLSessionDataTask = FakeURLSessionDataTask(), error: Error? = nil) {
            stubs[url] = Stub(task: task, error: error)
        }

        private struct Stub {
            let task: URLSessionDataTask
            let error: Error?
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

func withTaskTimeoutHandler<Success: Sendable>(
    timeout: Duration,
    operation: @Sendable @escaping () async throws -> Success,
    onTimeout handler: @Sendable @escaping () throws -> Success,
    isolation: isolated (any Actor)? = #isolation,
) async rethrows -> Success {
    try await withThrowingTaskGroup(returning: Success.self) { group in
        _ = group.addTaskUnlessCancelled {
            try await operation()
        }

        _ = group.addTaskUnlessCancelled { () -> Success in
            try await Task<Never, Never>.sleep(for: timeout, clock: .continuous)
            return try handler()
        }

        guard let result = try await group.next() else {
            throw TaskTimeoutError.missingValue
        }

        group.cancelAll()
        return result
    }
}

enum TaskTimeoutError: Error {
    case missingValue
}
