//
// XCTestCase+Snapshot.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import UIKit
import XCTest

extension XCTestCase {
    func record(snapshot: UIImage, named name: String, file: StaticString = #filePath, line: UInt = #line) {
        let snapshotURL = snapshotURL(named: name, file: file)
        let snapshotData = makeSnapshotData(for: snapshot, file: file, line: line)

        do {
            try FileManager.default.createDirectory(
                at: snapshotsDirectory(file: file),
                withIntermediateDirectories: true,
            )

            try snapshotData?.write(to: snapshotURL)

            XCTFail("Record succeeded - use `assert(snapshot:named:)` to compare the snapshot from now on.", file: file, line: line)
        } catch {
            XCTFail("Failed to record snapshot with error: \(error)", file: file, line: line)
        }
    }

    func assert(snapshot: UIImage, named name: String, file: StaticString = #filePath, line: UInt = #line) {
        let snapshotURL = snapshotURL(named: name, file: file)
        let snapshotData = makeSnapshotData(for: snapshot, file: file, line: line)

        guard let storedSnapshotData = try? Data(contentsOf: snapshotURL) else {
            return XCTFail("Failed to load stored snapshot at URL: '\(snapshotURL)'. Use the `record` method to store a snapshot before asserting", file: file, line: line)
        }

        if snapshotData != storedSnapshotData {
            let failureSnapshotURL = failureSnapshotsDirectory(file: file)
                .appending(path: snapshotURL.lastPathComponent)

            do {
                try FileManager.default.createDirectory(
                    at: failureSnapshotsDirectory(file: file),
                    withIntermediateDirectories: true,
                )

                try snapshotData?.write(to: failureSnapshotURL)

                XCTFail("New snapshot does not match stored snapshot. New snapshot URL: '\(failureSnapshotURL)'. Stored snapshot URL: '\(snapshotURL)'", file: file, line: line)
            } catch {
                XCTFail("Failed to record snapshot with error: \(error)", file: file, line: line)
            }
        }
    }

    private func snapshotsDirectory(file: StaticString) -> URL {
        URL(filePath: String(describing: file))
            .deletingLastPathComponent()
            .appending(path: "Snapshots")
    }

    private func snapshotURL(named name: String, file: StaticString) -> URL {
        snapshotsDirectory(file: file)
            .appending(path: "\(name).png")
    }

    private func failureSnapshotsDirectory(file: StaticString) -> URL {
        snapshotsDirectory(file: file)
            .appending(path: "FailureImages")
    }

    private func makeSnapshotData(for snapshot: UIImage, file: StaticString, line: UInt) -> Data? {
        try? XCTUnwrap(snapshot.pngData(), "Failed to generate PNG data representation from snapshot", file: file, line: line)
    }
}
