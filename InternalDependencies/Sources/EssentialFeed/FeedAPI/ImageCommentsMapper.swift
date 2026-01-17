//
// ImageCommentsMapper.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import Foundation

enum ImageCommentsMapper {
    static func map(_ data: Data, from response: HTTPURLResponse) throws(RemoteImageCommentsLoader.Error) -> [RemoteFeedItem] {
        guard isOK(response), let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw .invalidData
        }

        return root.items
    }

    // MARK: - Helpers

    private static func isOK(_ response: HTTPURLResponse) -> Bool {
        (200..<300).contains(response.statusCode)
    }

    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }
}
