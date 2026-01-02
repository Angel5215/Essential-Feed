//
// FeedItemsMapper.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import Foundation

enum FeedItemsMapper {
    static func map(_ data: Data, from response: HTTPURLResponse) throws(RemoteFeedLoader.Error) -> [RemoteFeedItem] {
        guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw .invalidData
        }

        return root.items
    }

    // MARK: - Helpers

    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }
}
