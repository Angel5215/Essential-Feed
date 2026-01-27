//
// FeedLocalizationTests.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

@_spi(Bundle) import EssentialFeed
import XCTest

final class FeedLocalizationTests: XCTestCase {
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Feed"
        let bundle = EssentialFeed.bundle

        assertLocalizedKeyAndValuesExist(in: bundle, for: table)
    }
}
