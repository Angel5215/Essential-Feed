//
// URLSessionHTTPClientTests.swift
// Copyright © 2025 Ángel Vázquez. All rights reserved.
//

import EssentialFeed
import Foundation
import Testing

@Suite(.timeLimit(.minutes(1)))
final class URLSessionHTTPClientTests {
    private let leakHelper = MemoryLeakHelper()

    init() {
        URLProtocolStub.startInterceptingRequests()
    }

    deinit {
        URLProtocolStub.stopInterceptingRequests()
    }

    @Test
    func `get from URL performs GET request with URL`() async {
        let url = anyURL()

        async let request = withCheckedContinuation { continuation in
            URLProtocolStub.observeRequests { request in
                continuation.resume(returning: request)
            }
        }

        makeSUT().get(from: url) { _ in }

        await #expect(request.url == url)
        await #expect(request.httpMethod == "GET")
    }

    @Test
    func `get from URL fails on request Error`() async {
        let requestError = anyNSError()

        let receivedError = await resultErrorFor(data: nil, response: nil, error: requestError) as? NSError

        #expect(receivedError?.domain == requestError.domain)
        #expect(receivedError?.code == requestError.code)
    }

    @Test
    func `get from URL fails on all invalid representation cases`() async {
        await #expect(resultErrorFor(data: nil, response: nil, error: nil) != nil)
        await #expect(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: nil) != nil)
        await #expect(resultErrorFor(data: anyData(), response: nil, error: nil) != nil)
        await #expect(resultErrorFor(data: anyData(), response: nil, error: anyNSError()) != nil)
        await #expect(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: anyNSError()) != nil)
        await #expect(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyNSError()) != nil)
        await #expect(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: anyNSError()) != nil)
        await #expect(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()) != nil)
        await #expect(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: nil) != nil)
    }

    @Test
    func `get from URL succeeds on HTTP URL response with data`() async {
        let data = anyData()
        let response = anyHTTPURLResponse()

        let receivedValues = await resultValuesFor(data: data, response: response, error: nil)

        #expect(receivedValues?.data == data)
        #expect(receivedValues?.response.url == response.url)
        #expect(receivedValues?.response.statusCode == response.statusCode)
    }

    @Test
    func `get from URL succeeds with empty data on HTTP URL response with nil data`() async {
        let response = anyHTTPURLResponse()

        let receivedValues = await resultValuesFor(data: nil, response: response, error: nil)

        let emptyData = Data()
        #expect(receivedValues?.data == emptyData)
        #expect(receivedValues?.response.url == response.url)
        #expect(receivedValues?.response.statusCode == response.statusCode)
    }

    // MARK: - Helpers

    private func makeSUT(sourceLocation: SourceLocation = #_sourceLocation) -> any HTTPClient {
        let sut = URLSessionHTTPClient()
        leakHelper.track(sut, sourceLocation: sourceLocation)
        return sut
    }

    private func resultErrorFor(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        sourceLocation: SourceLocation = #_sourceLocation,
    ) async -> Error? {
        let result = await resultFor(data: data, response: response, error: error, sourceLocation: sourceLocation)

        switch result {
        case let .failure(error):
            return error
        default:
            Issue.record("Expected failure, got \(result) instead", sourceLocation: sourceLocation)
            return nil
        }
    }

    private func resultValuesFor(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        sourceLocation: SourceLocation = #_sourceLocation,
    ) async -> (data: Data, response: HTTPURLResponse)? {
        let result = await resultFor(data: data, response: response, error: error, sourceLocation: sourceLocation)

        switch result {
        case let .success(data, response):
            return (data, response)
        default:
            Issue.record("Expected success, got \(result) instead.", sourceLocation: sourceLocation)
            return nil
        }
    }

    private func resultFor(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        sourceLocation: SourceLocation = #_sourceLocation,
    ) async -> HTTPClientResult {
        URLProtocolStub.stub(data: data, response: response, error: error)
        let sut = makeSUT(sourceLocation: sourceLocation)

        return await withCheckedContinuation { continuation in
            sut.get(from: anyURL()) { result in
                nonisolated(unsafe) let result = result
                continuation.resume(returning: result)
            }
        }
    }

    private func anyURL() -> URL {
        URL(string: "https://any-url.com")!
    }

    private func anyData() -> Data {
        Data("any data".utf8)
    }

    private func anyNSError() -> NSError {
        NSError(domain: "any error", code: 0)
    }

    private func nonHTTPURLResponse() -> URLResponse {
        URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }

    private func anyHTTPURLResponse() -> HTTPURLResponse {
        HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }

    private final class URLProtocolStub: URLProtocol {
        override class func canInit(with request: URLRequest) -> Bool {
            true
        }

        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            request
        }

        override func startLoading() {
            guard let stub = Self.stub else { return }

            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }

            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }

            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            } else {
                client?.urlProtocolDidFinishLoading(self)
            }

            stub.requestObserver?(request)
        }

        override func stopLoading() {}

        // MARK: - Helpers

        private nonisolated(unsafe) static var _stub: Stub?
        private static var stub: Stub? {
            get { queue.sync { _stub } }
            set { queue.sync { _stub = newValue } }
        }

        private static let queue = DispatchQueue(label: "URLProtocolStub.queue")

        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error, requestObserver: nil)
        }

        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            stub = Stub(data: nil, response: nil, error: nil, requestObserver: observer)
        }

        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }

        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
        }

        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
            let requestObserver: ((URLRequest) -> Void)?
        }
    }
}
