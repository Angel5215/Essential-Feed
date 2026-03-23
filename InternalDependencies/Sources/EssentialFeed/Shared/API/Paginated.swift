//
// Paginated.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

public struct Paginated<Item> {
    public typealias LoadMoreCompletion = (Result<Self, Error>) -> Void

    public let items: [Item]
    public let loadMore: ((LoadMoreCompletion) -> Void)?

    public init(items: [Item], loadMore: ((LoadMoreCompletion) -> Void)? = nil) {
        self.items = items
        self.loadMore = loadMore
    }
}
