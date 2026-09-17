//
// BuildConfigurationTests.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import Foundation
import XCTest

final class BuildConfigurationTests: XCTestCase {
    private var projectFile: String {
        URL(fileURLWithPath: (#filePath as NSString).deletingLastPathComponent)
            .appendingPathComponent("../../EssentialFeed.xcodeproj/project.xcproj")
            .standardizedFileURL
            .path(percentEncoded: false)
    }

    func test_hasExpectedNumberOfTargets() throws {
        let project = try loadProject()
        let targets = try XCTUnwrap(project["targets"] as? [[String: Any]], "Missing `targets` array")

        XCTAssertEqual(targets.count, 6, "Expected 6 targets in EssentialFeed.xcodeproj")
    }

    func test_allConfigurationsUseConfigurationFiles() throws {
        let project = try loadProject()

        let rootConfigurations = try XCTUnwrap(project["configurations"] as? [[String: Any]], "Missing root `configurations` array")

        for configuration in rootConfigurations {
            assertUsesConfigurationFile(configuration, context: "Project")
        }
        assertNoInlineBuildSettings(project, context: "Project")

        let targets = try XCTUnwrap(project["targets"] as? [[String: Any]], "Missing `targets` array")
        for target in targets {
            let targetName = target["name"] as? String ?? "<unknown target>"
            let specializedConfigurations = try XCTUnwrap(
                target["specialized-configurations"] as? [[String: Any]],
                "\(targetName) is missing `specialized-configurations`",
            )

            for configuration in specializedConfigurations {
                assertUsesConfigurationFile(configuration, context: targetName)
            }
            assertNoInlineBuildSettings(target, context: targetName)
        }
    }

    // MARK: - Helpers

    private func loadProject() throws -> [String: Any] {
        let rawContent = try String(contentsOfFile: projectFile, encoding: .utf8)
        let strictJSON = removingTrailingCommas(from: rawContent)
        let data = try XCTUnwrap(strictJSON.data(using: .utf8))
        let object = try JSONSerialization.jsonObject(with: data)
        return try XCTUnwrap(object as? [String: Any], "Unexpected root type in \(projectFile)")
    }

    private func removingTrailingCommas(from content: String) -> String {
        let pattern = #",(\s*[}\]])"#
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(content.startIndex..., in: content)
        return regex.stringByReplacingMatches(in: content, options: [], range: range, withTemplate: "$1")
    }

    private func assertUsesConfigurationFile(_ configuration: [String: Any], context: String, file: StaticString = #filePath, line: UInt = #line) {
        let name = configuration["name"] as? String ?? "<unknown configuration>"
        XCTAssertNotNil(
            configuration["file"],
            "\(context) configuration '\(name)' is missing a `file` reference to an .xcconfig",
            file: file,
            line: line,
        )
    }

    private func assertNoInlineBuildSettings(_ object: [String: Any], context: String, file: StaticString = #filePath, line: UInt = #line) {
        guard let buildSettings = object["build-settings"] as? [String: Any], !buildSettings.isEmpty else { return }

        XCTFail(
            "\(context) has inline build-settings overrides: \(buildSettings.keys.sorted().joined(separator: ", "))",
            file: file,
            line: line,
        )
    }
}
