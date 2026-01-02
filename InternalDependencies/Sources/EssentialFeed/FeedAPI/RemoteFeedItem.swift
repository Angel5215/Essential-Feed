//
// RemoteFeedItem.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import Foundation

struct RemoteFeedItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}
