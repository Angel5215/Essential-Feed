//
// FeedItemsMapper.swift
// Copyright © 2025 Ángel Vázquez. All rights reserved.
//

import Foundation

enum FeedItemsMapper {
    static func map(_ data: Data, response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == StatusCode.ok else {
            throw RemoteFeedLoader.Error.invalidData
        }

        let json = try JSONDecoder().decode(Root.self, from: data)
        return json.items.map(\.item)
    }

    // MARK: - Helpers

    private enum StatusCode {
        static let ok = 200
    }

    private struct Root: Decodable {
        let items: [Item]
    }

    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL

        var item: FeedItem {
            FeedItem(id: id, description: description, location: location, imageURL: image)
        }
    }
}
