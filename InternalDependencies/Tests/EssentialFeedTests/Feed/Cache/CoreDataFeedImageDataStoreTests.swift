//
// CoreDataFeedImageDataStoreTests.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import EssentialFeed
import XCTest

final class CoreDataFeedImageDataStoreTests: XCTestCase {
    func test_retrieveImageData_deliversImageDatanotFoundWhenEmpty() {
        let sut = makeSUT()

        expect(sut, toCompleteRetrievalWith: notFound(), for: anyURL())
    }

    func test_retrieveImageData_deliversNotFoundWhenStoredDataURLDoesNotMatch() throws {
        let sut = makeSUT()
        let url = try XCTUnwrap(URL(string: "https://a-url.com"))
        let nonMatchingURL = try XCTUnwrap(URL(string: "https://another-url.com"))

        insert(anyData(), for: url, into: sut)

        expect(sut, toCompleteRetrievalWith: notFound(), for: nonMatchingURL)
    }

    func test_retrieveImageData_deliversFoundDataWhenThereIsAStoredImageDataMatchingURL() throws {
        let sut = makeSUT()
        let storedData = anyData()
        let matchingURL = try XCTUnwrap(URL(string: "https://a-url.com"))

        insert(storedData, for: matchingURL, into: sut)

        expect(sut, toCompleteRetrievalWith: found(storedData), for: matchingURL)
    }

    func test_retrieveImageData_deliversLastInsertedValues() throws {
        let sut = makeSUT()
        let firstStoredData = Data("first".utf8)
        let lastStoredData = Data("last".utf8)
        let url = try XCTUnwrap(URL(string: "https://a-url.com"))

        insert(firstStoredData, for: url, into: sut)
        insert(lastStoredData, for: url, into: sut)

        expect(sut, toCompleteRetrievalWith: found(lastStoredData), for: url)
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CoreDataFeedStore {
        let storeURL = URL(filePath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func notFound() -> Result<Data?, Error> {
        .success(nil)
    }

    private func found(_ data: Data) -> Result<Data?, Error> {
        .success(data)
    }

    private func expect(
        _ sut: CoreDataFeedStore,
        toCompleteRetrievalWith expectedResult: Result<Data?, Error>,
        for url: URL,
        file: StaticString = #file,
        line: UInt = #line,
    ) {
        let receivedResult = Result { try sut.retrieve(dataForURL: url) }

        switch (receivedResult, expectedResult) {
        case let (.success(receivedData), .success(expectedData)):
            XCTAssertEqual(receivedData, expectedData, file: file, line: line)
        default:
            XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
        }
    }

    private func insert(
        _ data: Data,
        for url: URL,
        into sut: CoreDataFeedStore,
        file: StaticString = #filePath,
        line: UInt = #line,
    ) {
        do {
            let image = localImage(url: url)
            try sut.insert([image], timestamp: Date())
            try sut.insert(data, for: url)
        } catch {
            XCTFail("Failed to insert \(data) with error \(error)", file: file, line: line)
        }
    }

    private func localImage(url: URL) -> LocalFeedImage {
        LocalFeedImage(id: UUID(), description: "any", location: "any", url: url)
    }
}
