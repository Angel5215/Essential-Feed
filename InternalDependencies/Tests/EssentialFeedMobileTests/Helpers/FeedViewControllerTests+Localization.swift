//
// FeedViewControllerTests+Localization.swift
// Copyright © 2025 Ángel Vázquez. All rights reserved.
//

import EssentialFeedMobile
import XCTest

extension FeedViewControllerTests {
    func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "Feed"
        let bundle = FeedViewController.bundle
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key '\(key)' in table '\(table)'", file: file, line: line)
        }
        return value
    }
}
