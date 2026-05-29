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

    public func get(from url: URL) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await session.data(from: url)
        guard let response = response as? HTTPURLResponse else { throw UnexpectedValuesRepresentation() }
        return (data, response)
    }

    // MARK: - Helpers

    private struct UnexpectedValuesRepresentation: Error {}
}
