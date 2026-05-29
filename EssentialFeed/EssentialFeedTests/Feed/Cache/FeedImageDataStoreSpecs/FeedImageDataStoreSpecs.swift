//
// FeedImageDataStoreSpecs.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

protocol FeedImageDataStoreSpecs {
    func test_retrieveImageData_deliversNotFoundWhenEmpty() async throws
    func test_retrieveImageData_deliversNotFoundWhenStoredDataURLDoesNotMatch() async throws
    func test_retrieveImageData_deliversFoundDataWhenThereIsAStoredImageDataMatchingURL() async throws
    func test_retrieveImageData_deliversLastInsertedValue() async throws
}
