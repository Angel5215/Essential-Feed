//
// EssentialFeedAPIEndToEndTests.swift
// Copyright © 2025 Ángel Vázquez. All rights reserved.
//

import EssentialFeed
import Foundation
import Testing

@Suite(.timeLimit(.minutes(1)))
struct EssentialFeedAPIEndToEndTests {
    private let leakHelper = MemoryLeakHelper()

    @Test
    func `end to end test server GET feed result matches fixed test account data`() async {
        switch await getFeedResult() {
        case let .success(imageFeed):
            #expect(imageFeed.count == 8, "Expected 8 images in the test account image feed")
            #expect(imageFeed[0] == expectedImage(at: 0))
            #expect(imageFeed[1] == expectedImage(at: 1))
            #expect(imageFeed[2] == expectedImage(at: 2))
            #expect(imageFeed[3] == expectedImage(at: 3))
            #expect(imageFeed[4] == expectedImage(at: 4))
            #expect(imageFeed[5] == expectedImage(at: 5))
            #expect(imageFeed[6] == expectedImage(at: 6))
            #expect(imageFeed[7] == expectedImage(at: 7))

        case let .failure(error):
            Issue.record("Expected successful feed result, got \(error) instead")
        }
    }

    // MARK: - Helpers

    private func getFeedResult(sourceLocation: SourceLocation = #_sourceLocation) async -> LoadFeedResult {
        let testServerURL = URL(string: "https://gist.githubusercontent.com/Angel5215/bf2130a77e27fd39739c354d935b2916/raw/58d4ea46bf75d8804fb66ccf2eb28304323fe49a/test_api_feed")!
        let session = URLSession(configuration: .ephemeral)
        let client = URLSessionHTTPClient(session: session)
        let loader = RemoteFeedLoader(url: testServerURL, client: client)

        leakHelper.track(client, sourceLocation: sourceLocation)
        leakHelper.track(loader, sourceLocation: sourceLocation)

        return await withCheckedContinuation { continuation in
            loader.load { result in
                nonisolated(unsafe) let result = result
                continuation.resume(returning: result)
            }
        }
    }

    private func expectedImage(at index: Int) -> FeedImage {
        FeedImage(
            id: id(at: index),
            description: description(at: index),
            location: location(at: index),
            url: imageURL(at: index),
        )
    }

    private func id(at index: Int) -> UUID {
        UUID(uuidString: [
            "73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6",
            "BA298A85-6275-48D3-8315-9C8F7C1CD109",
            "5A0D45B3-8E26-4385-8C5D-213E160A5E3C",
            "FF0ECFE2-2879-403F-8DBE-A83B4010B340",
            "DC97EF5E-2CC9-4905-A8AD-3C351C311001",
            "557D87F1-25D3-4D77-82E9-364B2ED9CB30",
            "A83284EF-C2DF-415D-AB73-2A9B8B04950B",
            "F79BD7F8-063F-46E2-8147-A67635C3BB01",
        ][index])!
    }

    private func description(at index: Int) -> String? {
        [
            "Description 1",
            nil,
            "Description 3",
            nil,
            "Description 5",
            "Description 6",
            "Description 7",
            "Description 8",
        ][index]
    }

    private func location(at index: Int) -> String? {
        [
            "Location 1",
            "Location 2",
            nil,
            nil,
            "Location 5",
            "Location 6",
            "Location 7",
            "Location 8",
        ][index]
    }

    private func imageURL(at index: Int) -> URL {
        URL(string: [
            "https://url-1.com",
            "https://url-2.com",
            "https://url-3.com",
            "https://url-4.com",
            "https://url-5.com",
            "https://url-6.com",
            "https://url-7.com",
            "https://url-8.com",
        ][index])!
    }
}
