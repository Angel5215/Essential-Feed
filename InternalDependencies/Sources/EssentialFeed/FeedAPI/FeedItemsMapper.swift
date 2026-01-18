//
// FeedItemsMapper.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import Foundation

public enum FeedItemsMapper {
    public static func map(_ data: Data, from response: HTTPURLResponse) throws(RemoteFeedLoader.Error) -> [FeedImage] {
        guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw .invalidData
        }

        return root.images
    }

    // MARK: - Helpers

    private struct Root: Decodable {
        let items: [RemoteFeedItem]

        var images: [FeedImage] {
            items.map { item in
                FeedImage(id: item.id, description: item.description, location: item.location, url: item.image)
            }
        }
    }

    private struct RemoteFeedItem: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
    }
}
