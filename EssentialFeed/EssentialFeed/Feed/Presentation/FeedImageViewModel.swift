//
// FeedImageViewModel.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

public struct FeedImageViewModel {
    public let description: String?
    public let location: String?

    public var hasLocation: Bool {
        location != nil
    }
}
