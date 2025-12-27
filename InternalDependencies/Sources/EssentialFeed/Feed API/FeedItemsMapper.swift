//
// FeedItemsMapper.swift
// Copyright © 2025 Ángel Vázquez. All rights reserved.
//

import Foundation

enum FeedItemsMapper {
    static func map(_ data: Data, from response: HTTPURLResponse) throws(RemoteFeedLoader.Error) -> [RemoteFeedItem] {
        guard response.statusCode == StatusCode.ok,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw .invalidData
        }

        return root.items
    }

    // MARK: - Helpers

    private enum StatusCode {
        static let ok = 200
    }

    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }
}
