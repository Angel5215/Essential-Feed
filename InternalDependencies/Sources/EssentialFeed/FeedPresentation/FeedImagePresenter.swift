//
// FeedImagePresenter.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import Foundation

public enum FeedImagePresenter {
    public static func map(_ image: FeedImage) -> FeedImageViewModel {
        FeedImageViewModel(description: image.description, location: image.location)
    }
}
