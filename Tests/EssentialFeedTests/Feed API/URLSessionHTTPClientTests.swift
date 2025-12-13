//
// URLSessionHTTPClientTests.swift
// Copyright © 2025 Ángel Vázquez. All rights reserved.
//

import EssentialFeed
import Foundation
import Testing

final class URLSessionHTTPClient {
    private let session: URLSession

    init(session: URLSession = .shared) {
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

@Suite(.timeLimit(.minutes(1)))
struct URLSessionHTTPClientTests {
    @Test
    func `get from URL fails on request error`() async {
        URLProtocolStub.startInterceptingRequests()

        let url = URL(string: "https://any-url.com")!
        let error = NSError(domain: "any error", code: 1)
        URLProtocolStub.stub(url: url, data: nil, response: nil, error: error)

        let sut = URLSessionHTTPClient()

        await withCheckedContinuation { continuation in
            sut.get(from: url) { result in
                switch result {
                case let .failure(receivedError as NSError):
                    #expect(receivedError.domain == error.domain)
                    #expect(receivedError.code == error.code)
                default:
                    Issue.record("Expected failure with error \(error), got \(result) instead.")
                }

                continuation.resume()
            }
        }
        URLProtocolStub.stopInterceptingRequests()
    }

    // MARK: - Helpers

    private class URLProtocolStub: URLProtocol {
        private nonisolated(unsafe) static var stubs = [URL: Stub]()

        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else { return false }
            return stubs[url] != nil
        }

        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            request
        }

        override func startLoading() {
            guard let url = request.url, let stub = Self.stubs[url] else { return }

            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }

            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }

            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }

            client?.urlProtocolDidFinishLoading(self)
        }

        override func stopLoading() {}

        // MARK: - Helpers

        static func stub(url: URL, data: Data?, response: URLResponse?, error: Error?) {
            stubs[url] = Stub(data: data, response: response, error: error)
        }

        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }

        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stubs = [:]
        }

        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
    }
}
