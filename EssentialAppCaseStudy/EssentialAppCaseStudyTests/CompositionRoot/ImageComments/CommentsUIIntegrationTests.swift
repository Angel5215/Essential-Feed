//
// CommentsUIIntegrationTests.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import Combine
import EssentialAppCaseStudy
import EssentialFeed
import EssentialFeedMobile
import XCTest

final class CommentsUIIntegrationTests: FeedUIIntegrationTests {
    // MARK: - Localization

    func test_commentsView_hasTitle() {
        let (sut, _) = makeSUT()

        sut.simulateAppearance()

        XCTAssertEqual(sut.title, commentsTitle)
    }

    // MARK: - Load Feed Actions

    func test_loadCommentsActions_requestCommentsFromLoader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadCommentsCallCount, 0, "Expected no loading requests before the view is loaded")

        sut.simulateAppearance()
        XCTAssertEqual(loader.loadCommentsCallCount, 1, "Expected a loading request once the view is loaded")

        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 2, "Expected another loading request once the user initiates a load")

        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 3, "Expected a third request once the user initiates another load")
    }

    // MARK: - Loading Indicator

    func test_loadingCommentsIndicator_isVisibleWhileLoadingComments() {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once the view is loaded")

        loader.completeCommentsLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully")

        sut.simulateUserInitiatedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")

        loader.completeCommentsLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes with an error")
    }

    // MARK: - Load Feed Completion

    func test_loadCommentsCompletion_rendersSuccessfullyLoadedComments() {
        let comment0 = makeComment(message: "a message", username: "a username")
        let comment1 = makeComment(message: "another message", username: "another username")
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        assertThat(sut, isRendering: [ImageComment]())

        loader.completeCommentsLoading(with: [comment0], at: 0)
        assertThat(sut, isRendering: [comment0])

        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoading(with: [comment0, comment1], at: 1)
        assertThat(sut, isRendering: [comment0, comment1])
    }

    func test_loadCommentsCompletion_rendersSuccessfullyLoadedEmptyCommentsAfterNonEmptyComments() {
        let comment = makeComment()
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        assertThat(sut, isRendering: [ImageComment]())

        loader.completeCommentsLoading(with: [comment], at: 0)
        assertThat(sut, isRendering: [comment])

        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoading(with: [], at: 1)
        assertThat(sut, isRendering: [ImageComment]())
    }

    func test_loadCommentsCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let comment = makeComment()
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeCommentsLoading(with: [comment], at: 0)
        assertThat(sut, isRendering: [comment])

        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoadingWithError(at: 1)
        assertThat(sut, isRendering: [comment])
    }

    override func test_loadFeedCompletion_rendersErrorMessageOnErrorUntilNextReload() {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        XCTAssertNil(sut.errorMessage)

        loader.completeCommentsLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)

        sut.simulateUserInitiatedReload()
        XCTAssertNil(sut.errorMessage)
    }

    // MARK: - Error view

    override func test_tapOnErrorView_hidesErrorMessage() {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        XCTAssertNil(sut.errorMessage)

        loader.completeCommentsLoadingWithError()
        XCTAssertEqual(sut.errorMessage, loadError)

        sut.simulateErrorViewTap()
        XCTAssertNil(sut.errorMessage)
    }

    // MARK: - Concurrency

    override func test_loadFeedCompletion_dispatchesFromBackgroundToMainThread() {
        let image = makeComment()
        let (sut, loader) = makeSUT()
        sut.simulateAppearance()

        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completeCommentsLoading(with: [image], at: 0)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = CommentsUIComposer.commentsComposedWith(commentsLoader: loader.loadPublisher)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
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

    final class LoaderSpy {
        // MARK: - FeedLoader

        private var requests = [PassthroughSubject<[ImageComment], Error>]()

        var loadCommentsCallCount: Int {
            requests.count
        }

        func completeCommentsLoading(with comments: [ImageComment] = [], at index: Int = 0) {
            requests[index].send(comments)
        }

        func completeCommentsLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            requests[index].send(completion: .failure(error))
        }

        func loadPublisher() -> AnyPublisher<[ImageComment], Error> {
            let publisher = PassthroughSubject<[ImageComment], Error>()
            requests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }
    }
}
