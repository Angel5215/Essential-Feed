//
// Scheduler.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import EssentialFeed

typealias ScheduledStore = FeedImageDataStore & FeedStore & Scheduler & Sendable

protocol Scheduler {
    @MainActor
    func schedule<T>(_ action: @Sendable @escaping () throws -> T) async rethrows -> T
}

extension CoreDataFeedStore: Scheduler {
    @MainActor
    func schedule<T>(_ action: @Sendable @escaping () throws -> T) async rethrows -> T {
        if contextQueue == .main {
            try action()
        } else {
            try await perform(action)
        }
    }
}

extension InMemoryFeedStore: Scheduler {
    @MainActor
    func schedule<T>(_ action: @Sendable @escaping () throws -> T) async rethrows -> T {
        try action()
    }
}
