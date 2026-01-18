//
// ImageCommentsMapper.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import Foundation

public enum ImageCommentsMapper {
    public static func map(_ data: Data, from response: HTTPURLResponse) throws(RemoteImageCommentsLoader.Error) -> [ImageComment] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard isOK(response), let root = try? decoder.decode(Root.self, from: data) else {
            throw .invalidData
        }

        return root.comments
    }

    // MARK: - Helpers

    private static func isOK(_ response: HTTPURLResponse) -> Bool {
        (200..<300).contains(response.statusCode)
    }

    private struct Root: Decodable {
        private let items: [Item]

        var comments: [ImageComment] {
            items.map { item in
                ImageComment(id: item.id, message: item.message, creationDate: item.creationDate, username: item.author.username)
            }
        }
    }

    private struct Item: Decodable {
        let id: UUID
        let message: String
        let creationDate: Date
        let author: Author

        enum CodingKeys: String, CodingKey {
            case id
            case message
            case creationDate = "created_at"
            case author
        }
    }

    private struct Author: Decodable {
        let username: String
    }
}
