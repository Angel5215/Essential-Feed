//
// CommentsUIIntegrationTests.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import EssentialAppCaseStudy
import EssentialFeed
import EssentialFeedMobile
import XCTest

@MainActor
final class CommentsUIIntegrationTests: XCTestCase {
    // MARK: - Localization

    func test_commentsView_hasTitle() {
        let (sut, _) = makeSUT()

        sut.simulateAppearance()

        XCTAssertEqual(sut.title, commentsTitle)
    }

    // MARK: - Load Comments Actions

    func test_loadCommentsActions_requestCommentsFromLoader() async {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadCommentsCallCount, 0, "Expected no loading requests before the view is loaded")

        sut.simulateAppearance()
        XCTAssertEqual(loader.loadCommentsCallCount, 1, "Expected a loading request once the view is loaded")

        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 1, "Expected no requests until previous completes")

        await loader.completeCommentsLoading(at: 0)
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 2, "Expected another loading request once the user initiates a load")

        await loader.completeCommentsLoading(at: 1)
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 3, "Expected a third request once the user initiates another load")
    }

    // MARK: - Loading Indicator

    func test_loadingCommentsIndicator_isVisibleWhileLoadingComments() async {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once the view is loaded")

        await loader.completeCommentsLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully")

        sut.simulateUserInitiatedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")

        await loader.completeCommentsLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes with an error")
    }

    // MARK: - Load Comments Completion

    func test_loadCommentsCompletion_rendersSuccessfullyLoadedComments() async {
        let comment0 = makeComment(message: "a message", username: "a username")
        let comment1 = makeComment(message: "another message", username: "another username")
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        assertThat(sut, isRendering: [ImageComment]())

        await loader.completeCommentsLoading(with: [comment0], at: 0)
        assertThat(sut, isRendering: [comment0])

        sut.simulateUserInitiatedReload()
        await loader.completeCommentsLoading(with: [comment0, comment1], at: 1)
        assertThat(sut, isRendering: [comment0, comment1])
    }

    func test_loadCommentsCompletion_rendersSuccessfullyLoadedEmptyCommentsAfterNonEmptyComments() async {
        let comment = makeComment()
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        assertThat(sut, isRendering: [ImageComment]())

        await loader.completeCommentsLoading(with: [comment], at: 0)
        assertThat(sut, isRendering: [comment])

        sut.simulateUserInitiatedReload()
        await loader.completeCommentsLoading(with: [], at: 1)
        assertThat(sut, isRendering: [ImageComment]())
    }

    func test_loadCommentsCompletion_doesNotAlterCurrentRenderingStateOnError() async {
        let comment = makeComment()
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        await loader.completeCommentsLoading(with: [comment], at: 0)
        assertThat(sut, isRendering: [comment])

        sut.simulateUserInitiatedReload()
        await loader.completeCommentsLoadingWithError(at: 1)
        assertThat(sut, isRendering: [comment])
    }

    func test_loadCommentsCompletion_rendersErrorMessageOnErrorUntilNextReload() async {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        XCTAssertNil(sut.errorMessage)

        await loader.completeCommentsLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)

        sut.simulateUserInitiatedReload()
        XCTAssertNil(sut.errorMessage)
    }

    // MARK: - Error view

    func test_tapOnErrorView_hidesErrorMessage() async {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        XCTAssertNil(sut.errorMessage)

        await loader.completeCommentsLoadingWithError()
        XCTAssertEqual(sut.errorMessage, loadError)

        sut.simulateErrorViewTap()
        XCTAssertNil(sut.errorMessage)
    }

    // MARK: - Deinit

    func test_deinit_cancelsRunningRequest() async throws {
        let loader = LoaderSpy()
        var sut: ListViewController?

        autoreleasepool {
            sut = CommentsUIComposer.commentsComposedWith(commentsLoader: loader.loadComments)
            sut?.simulateAppearance()
        }

        XCTAssertEqual(loader.cancelledCommentsCallCount, 0)

        sut = nil
        let result = try await loader.result(at: 0)
        XCTAssertEqual(result, .cancelled)
        XCTAssertEqual(loader.cancelledCommentsCallCount, 1)
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = CommentsUIComposer.commentsComposedWith(commentsLoader: loader.loadComments)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)

        addTeardownBlock { [weak loader] in
            try await loader?.cancelPendingRequests()
        }

        return (sut, loader)
    }

    private func assertThat(_ sut: ListViewController, isRendering comments: [ImageComment], file: StaticString = #filePath, line: UInt = #line) {
        sut.enforceLayoutCycleToRenderTable()

        guard sut.numberOfRenderedComments() == comments.count else {
            return XCTFail("Expected \(comments.count) comments, got \(sut.numberOfRenderedComments()) instead", file: file, line: line)
        }

        let viewModel = ImageCommentsPresenter.map(comments)

        for (index, comment) in viewModel.comments.enumerated() {
            XCTAssertEqual(sut.commentMessage(at: index), comment.message, "Message at index '\(index)'", file: file, line: line)
            XCTAssertEqual(sut.commentDate(at: index), comment.date, "Creation date at index '\(index)'", file: file, line: line)
            XCTAssertEqual(sut.commentUsername(at: index), comment.username, "Username at index '\(index)'", file: file, line: line)
        }
    }

    private func makeComment(
        message: String = "any message",
        username: String = "any username",
        url: URL = URL(string: "https://any-url.com")!,
    ) -> ImageComment {
        ImageComment(id: UUID(), message: message, creationDate: Date(), username: username)
    }

    @MainActor
    private final class LoaderSpy {
        var loader = EssentialAppCaseStudyTests.LoaderSpy<Void, [ImageComment]>()

        var loadCommentsCallCount: Int {
            loader.requests.count
        }

        var cancelledCommentsCallCount: Int {
            loader.requests.count { $0.result == .cancelled }
        }

        func loadComments() async throws -> [ImageComment] {
            try await loader.load(from: ())
        }

        func completeCommentsLoading(with comments: [ImageComment] = [], at index: Int = 0) async {
            await loader.complete(with: comments, at: index)
        }

        func completeCommentsLoadingWithError(at index: Int = 0) async {
            let error = NSError(domain: "an error", code: 0)
            await loader.fail(with: error, at: index)
        }

        func result(at index: Int, timeout: TimeInterval = 1) async throws -> AsyncResult {
            try await loader.result(at: index, timeout: timeout)
        }

        func cancelPendingRequests() async throws {
            try await loader.cancelPendingRequests()
        }
    }
}
