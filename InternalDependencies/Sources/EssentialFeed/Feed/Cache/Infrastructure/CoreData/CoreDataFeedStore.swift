//
// CoreDataFeedStore.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import CoreData
import Foundation

public final class CoreDataFeedStore {
    private static let modelName = "FeedStore"
    private static let model = NSManagedObjectModel.with(name: modelName, in: .module)
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext

    enum StoreError: Error {
        case modelNotFound
        case failedToLoadPersistentContainer(Error)
    }

    public init(storeURL: URL) throws {
        guard let model = CoreDataFeedStore.model else {
            throw StoreError.modelNotFound
        }

        do {
            self.container = try NSPersistentContainer.load(name: CoreDataFeedStore.modelName, model: model, url: storeURL)
            self.context = container.newBackgroundContext()
        } catch {
            throw StoreError.failedToLoadPersistentContainer(error)
        }
    }

    deinit {
        cleanupReferencesToPersistentStores()
    }

    func performSync<Value>(action: (NSManagedObjectContext) -> Result<Value, Error>) throws -> Value {
        let context = context
        var result: Result<Value, Error>!
        context.performAndWait { result = action(context) }
        return try result.get()
    }

    private func cleanupReferencesToPersistentStores() {
        context.performAndWait {
            let coordinator = self.container.persistentStoreCoordinator
            try? coordinator.persistentStores.forEach(coordinator.remove)
        }
    }
}
