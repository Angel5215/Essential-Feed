//
// BuildConfigurationTests.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import Foundation
import Testing

struct BuildConfigurationTests {
    private var projectFile: String {
        URL(fileURLWithPath: (#filePath as NSString).deletingLastPathComponent)
            .appendingPathComponent("../../EssentialAppCaseStudy.xcodeproj/project.xcproj")
            .standardizedFileURL
            .path(percentEncoded: false)
    }

    @Test
    func `EssentialAppCaseStudy project has the expected number of targets`() throws {
        let project = try loadProject()
        let targets = try #require(project["targets"] as? [[String: Any]], "Missing `targets` array")

        #expect(targets.count == 2, "Expected 2 targets in EssentialAppCaseStudy.xcodeproj")
    }

    @Test
    func `EssentialAppCaseStudy project configurations all reference configuration files`() throws {
        let project = try loadProject()

        let rootConfigurations = try #require(project["configurations"] as? [[String: Any]], "Missing root `configurations` array")

        for configuration in rootConfigurations {
            assertUsesConfigurationFile(configuration, context: "Project")
        }
        assertNoInlineBuildSettings(project, context: "Project")

        let targets = try #require(project["targets"] as? [[String: Any]], "Missing `targets` array")
        for target in targets {
            let targetName = target["name"] as? String ?? "<unknown target>"
            let specializedConfigurations = try #require(
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
        let data = try #require(strictJSON.data(using: .utf8))
        let object = try JSONSerialization.jsonObject(with: data)
        return try #require(object as? [String: Any], "Unexpected root type in \(projectFile)")
    }

    private func removingTrailingCommas(from content: String) -> String {
        let pattern = #",(\s*[}\]])"#
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(content.startIndex..., in: content)
        return regex.stringByReplacingMatches(in: content, options: [], range: range, withTemplate: "$1")
    }

    private func assertUsesConfigurationFile(_ configuration: [String: Any], context: String, sourceLocation: SourceLocation = #_sourceLocation) {
        let name = configuration["name"] as? String ?? "<unknown configuration>"
        #expect(
            configuration["file"] != nil,
            "\(context) configuration '\(name)' is missing a `file` reference to an .xcconfig",
            sourceLocation: sourceLocation,
        )
    }

    private func assertNoInlineBuildSettings(_ object: [String: Any], context: String, sourceLocation: SourceLocation = #_sourceLocation) {
        guard let buildSettings = object["build-settings"] as? [String: Any], !buildSettings.isEmpty else { return }

        Issue.record(
            "\(context) has inline build-settings overrides: \(buildSettings.keys.sorted().joined(separator: ", "))",
            sourceLocation: sourceLocation,
        )
    }
}
