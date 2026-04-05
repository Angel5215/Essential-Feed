//
// SharedLocalizationTests.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

@_spi(Bundle) import EssentialFeed
import XCTest

@MainActor
final class SharedLocalizationTests: XCTestCase {
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Shared"
        let bundle = EssentialFeed.bundle

        assertLocalizedKeyAndValuesExist(in: bundle, for: table)
    }
}
