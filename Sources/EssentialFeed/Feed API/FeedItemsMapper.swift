//
// FeedItemsMapper.swift
// Copyright © 2025 Ángel Vázquez. All rights reserved.
//

import Foundation

enum FeedItemsMapper {
    static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == StatusCode.ok,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }

        return .success(root.feed)
    }

    // MARK: - Helpers

    private enum StatusCode {
        static let ok = 200
    }

    private struct Root: Decodable {
        let items: [Item]

        var feed: [FeedItem] {
            items.map(\.item)
        }
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
