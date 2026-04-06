//
// URLSessionHTTPClient.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import Foundation

public final class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession

    public init(session: URLSession) {
        self.session = session
    }

    private struct URLSessionTaskWrapper: HTTPClientTask {
        let wrappedTask: URLSessionTask

        func cancel() {
            wrappedTask.cancel()
        }
    }

    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        let task = session.dataTask(with: url) { data, response, error in
            completion(Result {
                if let error {
                    throw error
                } else if let data, let response = response as? HTTPURLResponse {
                    return (data, response)
                } else {
                    throw UnexpectedValuesRepresentation()
                }
            })
        }
        task.resume()
        return URLSessionTaskWrapper(wrappedTask: task)
    }

    // MARK: - Helpers

    private struct UnexpectedValuesRepresentation: Error {}
}
