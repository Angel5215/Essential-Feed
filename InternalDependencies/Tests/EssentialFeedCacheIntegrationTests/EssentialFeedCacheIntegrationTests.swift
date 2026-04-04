//
// EssentialFeedCacheIntegrationTests.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import EssentialFeed
import XCTest

final class EssentialFeedCacheIntegrationTests: XCTestCase {
    override func setUp() {
        super.setUp()

        setupEmptyStoreState()
    }

    override func tearDown() {
        super.tearDown()

        undoStoreSideEffects()
    }

    func test_load_deliversNoItemsOnEmptyCache() throws {
        let sut = try makeFeedLoader()

        expect(sut, toLoad: [])
    }

    func test_load_deliversItemsSavedOnASeparateInstance() throws {
        let sutToPerformSave = try makeFeedLoader()
        let sutToPerformLoad = try makeFeedLoader()
        let feed = uniqueImageFeed().models

        save(feed, with: sutToPerformSave)

        expect(sutToPerformLoad, toLoad: feed)
    }

    func test_save_overridesItemsSavedOnASeparateInstance() throws {
        let sutToPerformFirstSave = try makeFeedLoader()
        let sutToPerformLastSave = try makeFeedLoader()
        let sutToPerformLoad = try makeFeedLoader()
        let firstFeed = uniqueImageFeed().models
        let latestFeed = uniqueImageFeed().models

        save(firstFeed, with: sutToPerformFirstSave)

        save(latestFeed, with: sutToPerformLastSave)

        expect(sutToPerformLoad, toLoad: latestFeed)
    }

    func test_loadImageData_deliversSavedDataOnASeparateInstance() throws {
        let imageLoaderToPerformSave = try makeImageLoader()
        let imageLoaderToPerformLoad = try makeImageLoader()
        let feedLoader = try makeFeedLoader()
        let image = uniqueImage()
        let dataToSave = anyData()

        save([image], with: feedLoader)
        save(dataToSave, for: image.url, with: imageLoaderToPerformSave)

        expect(imageLoaderToPerformLoad, toLoad: dataToSave, for: image.url)
    }

    func test_saveImageData_overridesSavedImageDataOnASeparateInstance() throws {
        let imageLoaderToPerformFirstSave = try makeImageLoader()
        let imageLoaderToPerformLastSave = try makeImageLoader()
        let imageLoaderToPerformLoad = try makeImageLoader()
        let feedLoader = try makeFeedLoader()
        let image = uniqueImage()
        let firstDataToSave = Data("first".utf8)
        let lastImageData = Data("last".utf8)

        save([image], with: feedLoader)
        save(firstDataToSave, for: image.url, with: imageLoaderToPerformFirstSave)
        save(lastImageData, for: image.url, with: imageLoaderToPerformLastSave)

        expect(imageLoaderToPerformLoad, toLoad: lastImageData, for: image.url)
    }

    func test_validateFeedCache_doesNotDeleteRecentlySavedFeed() throws {
        let feedLoaderToPerformSave = try makeFeedLoader()
        let feedLoaderToPerformValidation = try makeFeedLoader()
        let feed = uniqueImageFeed().models

        save(feed, with: feedLoaderToPerformSave)
        validateCache(with: feedLoaderToPerformValidation)

        expect(feedLoaderToPerformSave, toLoad: feed)
    }

    func test_validateFeedCache_deletesFeedSavedInADistantPast() throws {
        let feedLoaderToPerformSave = try makeFeedLoader(currentDate: .distantPast)
        let feedLoaderToPerformValidation = try makeFeedLoader(currentDate: Date())
        let feed = uniqueImageFeed().models

        save(feed, with: feedLoaderToPerformSave)
        validateCache(with: feedLoaderToPerformValidation)

        expect(feedLoaderToPerformSave, toLoad: [])
    }

    // MARK: - Helpers

    private func makeFeedLoader(
        currentDate: Date = Date(),
        file: StaticString = #filePath,
        line: UInt = #line,
    ) throws -> LocalFeedLoader {
        let storeURL = testSpecificStoreURL()
        let store = try CoreDataFeedStore(storeURL: storeURL, contextQueue: .main)
        let sut = LocalFeedLoader(store: store, currentDate: { currentDate })
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return sut
    }

    private func makeImageLoader(file: StaticString = #filePath, line: UInt = #line) throws -> LocalFeedImageDataLoader {
        let storeURL = testSpecificStoreURL()
        let store = try CoreDataFeedStore(storeURL: storeURL, contextQueue: .main)
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return sut
    }

    private func expect(
        _ sut: LocalFeedLoader,
        toLoad expectedFeed: [FeedImage],
        file: StaticString = #filePath,
        line: UInt = #line,
    ) {
        do {
            let loadedFeed = try sut.load()
            XCTAssertEqual(loadedFeed, expectedFeed, file: file, line: line)
        } catch {
            XCTFail("Expected successful feed result, got \(error) instead", file: file, line: line)
        }
    }

    private func save(
        _ feed: [FeedImage],
        with loader: LocalFeedLoader,
        file: StaticString = #filePath,
        line: UInt = #line,
    ) {
        do {
            try loader.save(feed)
        } catch {
            XCTFail("Expected to save feed successfully, got \(error) instead", file: file, line: line)
        }
    }

    private func save(
        _ data: Data,
        for url: URL,
        with loader: LocalFeedImageDataLoader,
        file: StaticString = #filePath,
        line: UInt = #line,
    ) {
        do {
            try loader.save(data, for: url)
        } catch {
            XCTFail("Expected to save image data successfully, got \(error) instead", file: file, line: line)
        }
    }

    private func expect(
        _ sut: LocalFeedImageDataLoader,
        toLoad expectedData: Data,
        for url: URL,
        file: StaticString = #filePath,
        line: UInt = #line,
    ) {
        do {
            let loadedData = try sut.loadImageData(from: url)
            XCTAssertEqual(loadedData, expectedData, file: file, line: line)
        } catch {
            XCTFail("Expected successful image data result, got \(error) instead", file: file, line: line)
        }
    }

    private func validateCache(with loader: LocalFeedLoader, file: StaticString = #filePath, line: UInt = #line) {
        do {
            try loader.validateCache()
        } catch {
            XCTFail("Expected to validate feed successfully, got \(error)", file: file, line: line)
        }
    }

    private func testSpecificStoreURL() -> URL {
        cachesDirectory().appending(path: "\(type(of: self)).store")
    }

    private func cachesDirectory() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    }

    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }

    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }

    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
}
