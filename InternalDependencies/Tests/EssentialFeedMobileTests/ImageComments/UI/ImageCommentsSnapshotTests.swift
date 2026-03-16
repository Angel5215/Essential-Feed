//
// ImageCommentsSnapshotTests.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import EssentialFeed
import EssentialFeedMobile
import XCTest

final class ImageCommentsSnapshotTests: XCTestCase {
    func test_display_listWithComments() {
        let sut = makeSUT()

        sut.display(comments())

        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "IMAGE_COMMENTS_light")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "IMAGE_COMMENTS_dark")
    }

    // MARK: - Helpers

    private func makeSUT() -> ListViewController {
        let controller = UIStoryboard.imageComments.instantiateInitialViewController() as! ListViewController
        controller.loadViewIfNeeded()
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        return controller
    }

    private func comments() -> [CellController] {
        commentControllers().map { CellController(dataSource: $0) }
    }

    private func commentControllers() -> [ImageCommentCellController] {
        [
            ImageCommentCellController(
                model: ImageCommentViewModel(
                    message: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
                    date: "1000 years ago",
                    username: "a long long long long username",
                )
            ),
            ImageCommentCellController(
                model: ImageCommentViewModel(
                    message: "East Side Gallery\nMemorial in Berlin, Germany",
                    date: "10 days ago",
                    username: "a username",
                )
            ),
            ImageCommentCellController(
                model: ImageCommentViewModel(
                    message: "nice",
                    date: "1 hour ago",
                    username: "a.",
                )
            ),
        ]
    }
}
