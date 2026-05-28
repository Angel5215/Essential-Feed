//
// ImageCommentsLocalizationTests.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

@_spi(Bundle) import EssentialFeed
import XCTest

@MainActor
final class ImageCommentsLocalizationTests: XCTestCase {
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "ImageComments"
        let bundle = Bundle.essentialFeed

        assertLocalizedKeyAndValuesExist(in: bundle, for: table)
    }
}
