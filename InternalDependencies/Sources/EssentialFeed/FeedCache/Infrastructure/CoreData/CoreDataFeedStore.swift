//
// CoreDataFeedStore.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import CoreData
import Foundation

public final class CoreDataFeedStore {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext

    public init(storeURL: URL, bundle: Bundle = .main) throws {
        self.container = try NSPersistentContainer.load(modelName: "FeedStore", url: storeURL, in: bundle)
        self.context = container.newBackgroundContext()
    }

    func perform(action: @escaping (NSManagedObjectContext) -> Void) {
        let context = context
        context.perform { action(context) }
    }
}
