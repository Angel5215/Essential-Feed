//
// FeedUIIntegrationTests+Assertions.swift
// Copyright © 2025 Ángel Vázquez. All rights reserved.
//

import EssentialFeed
import EssentialFeedMobile
import XCTest

extension FeedUIIntegrationTests {
    func assertThat(_ sut: FeedViewController, isRendering feed: [FeedImage], file: StaticString = #filePath, line: UInt = #line) {
        guard sut.numberOfRenderedFeedImageViews() == feed.count else {
            return XCTFail("Expected \(feed.count) images, got \(sut.numberOfRenderedFeedImageViews()) instead", file: file, line: line)
        }

        for (index, image) in feed.enumerated() {
            assertThat(sut, hasViewConfiguredFor: image, at: index, file: file, line: line)
        }
    }

    func assertThat(_ sut: FeedViewController, hasViewConfiguredFor image: FeedImage, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
        let view = sut.feedImageView(at: index)

        guard let cell = view as? FeedImageCell else {
            return XCTFail("Expected \(FeedImageCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }

        let shouldLocationBeVisible = image.location != nil
        XCTAssertEqual(
            cell.isShowingLocation,
            shouldLocationBeVisible,
            "Expected `isShowingLocation` to be \(shouldLocationBeVisible) for image view at index (\(index))",
            file: file,
            line: line,
        )

        XCTAssertEqual(
            cell.locationText,
            image.location,
            "Expected location text to be \(image.location, default: "[No location]") for image view at index (\(index))",
            file: file,
            line: line,
        )

        XCTAssertEqual(
            cell.descriptionText,
            image.description,
            "Expected description text to be \(image.description, default: "[No description]") for image view at index (\(index))",
            file: file,
            line: line,
        )
    }
}
