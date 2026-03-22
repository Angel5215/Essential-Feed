//
// ImageCommentsPresenter.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import Foundation

public struct ImageCommentsViewModel {
    public let comments: [ImageCommentViewModel]
}

public struct ImageCommentViewModel: Hashable {
    public let message: String
    public let date: String
    public let username: String

    public init(message: String, date: String, username: String) {
        self.message = message
        self.date = date
        self.username = username
    }
}

public enum ImageCommentsPresenter {
    public static var title: String {
        String(localized: "IMAGE_COMMENTS_VIEW_TITLE", table: "ImageComments", bundle: .module, comment: "Title for the feed view")
    }

    public static func map(
        _ comments: [ImageComment],
        currentDate: Date = Date(),
        calendar: Calendar = .current,
        locale: Locale = .current,
    ) -> ImageCommentsViewModel {
        let formatter = RelativeDateTimeFormatter()
        formatter.calendar = calendar
        formatter.locale = locale

        return ImageCommentsViewModel(
            comments: comments.map { comment in
                ImageCommentViewModel(
                    message: comment.message,
                    date: formatter.localizedString(for: comment.creationDate, relativeTo: Date()),
                    username: comment.username,
                )
            }
        )
    }
}
