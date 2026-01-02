//
// FeedImageViewModel.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

public struct FeedImageViewModel<Image> {
    public let description: String?
    public let location: String?
    public let image: Image?
    public let isLoading: Bool
    public let shouldRetry: Bool

    public var hasLocation: Bool {
        location != nil
    }
}
