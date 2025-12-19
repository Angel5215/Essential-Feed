//
// Testing+MemoryLeakTracking.swift
// Copyright © 2025 Ángel Vázquez. All rights reserved.
//

import Testing

final class MemoryLeakHelper {
    private var references = [WeakReference]()

    func track(_ instance: AnyObject, sourceLocation: SourceLocation) {
        references.append(WeakReference(object: instance, sourceLocation: sourceLocation))
    }

    deinit {
        for reference in references {
            #expect(
                reference.object == nil,
                "Instance should have been deallocated. Potential memory leak.",
                sourceLocation: reference.sourceLocation,
            )
        }
    }

    // MARK: - Helpers

    private final class WeakReference {
        weak var object: AnyObject?
        let sourceLocation: SourceLocation

        init(object: AnyObject? = nil, sourceLocation: SourceLocation) {
            self.object = object
            self.sourceLocation = sourceLocation
        }
    }
}
