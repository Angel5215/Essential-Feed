//
// ImageComment.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import Foundation

public struct ImageComment: Equatable {
    public let id: UUID
    public let message: String
    public let creationDate: Date
    public let username: String

    public init(id: UUID, message: String, creationDate: Date, username: String) {
        self.id = id
        self.message = message
        self.creationDate = creationDate
        self.username = username
    }
}
