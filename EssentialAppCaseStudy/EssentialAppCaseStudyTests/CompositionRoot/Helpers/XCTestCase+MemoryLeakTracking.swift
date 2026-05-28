//
// XCTestCase+MemoryLeakTracking.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import XCTest

extension XCTestCase {
    @MainActor
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak", file: file, line: line)
        }
    }
}
