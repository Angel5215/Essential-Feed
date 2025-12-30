//
// FeedErrorViewModel.swift
// Copyright © 2025 Ángel Vázquez. All rights reserved.
//

struct FeedErrorViewModel {
    let message: String?

    static var noError: FeedErrorViewModel {
        FeedErrorViewModel(message: nil)
    }

    static func error(message: String) -> FeedErrorViewModel {
        FeedErrorViewModel(message: message)
    }
}
