//
// BuildConfigurationTests.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import Foundation
import XCTest

final class BuildConfigurationTests: XCTestCase {
    private var pbxprojPath: String {
        let currentFilePath = (#filePath as NSString).deletingLastPathComponent
        return URL(fileURLWithPath: currentFilePath)
            .appendingPathComponent("../../EssentialFeed.xcodeproj/project.pbxproj")
            .standardizedFileURL
            .path(percentEncoded: false)
    }

    func test_hasExpectedNumberOfTargets() throws {
        let content = try String(contentsOfFile: pbxprojPath, encoding: .utf8)
        let targetCount = content.components(separatedBy: "isa = PBXNativeTarget;").count - 1
        XCTAssertEqual(targetCount, 6, "Expected 6 PBXNativeTarget entries in EssentialFeed.xcodeproj")
    }

    func test_allConfigurationsUseXcconfigFiles() throws {
        let content = try String(contentsOfFile: pbxprojPath, encoding: .utf8)
        let configurations = try parseConfigurations(from: content)

        XCTAssertFalse(configurations.isEmpty, "No XCBuildConfiguration entries found")

        for config in configurations {
            XCTAssertTrue(
                config.hasBaseConfiguration,
                "\(config.name) is missing baseConfigurationReference",
            )
            XCTAssertTrue(
                config.buildSettings.isEmpty,
                "\(config.name) has inline buildSettings overrides: \(config.buildSettings.joined(separator: ", "))",
            )
        }
    }

    // MARK: - Helpers

    private func parseConfigurations(from content: String) throws -> [ParsedConfiguration] {
        let pattern = #"isa\s*=\s*XCBuildConfiguration;\s*\n\s*baseConfigurationReferenceAnchor\s*=\s*(\w+)\s*/\*\s*([^*]+)\s*\*/;\s*\n\s*baseConfigurationReferenceRelativePath\s*=\s*([\w.]+)\s*;\s*\n\s*buildSettings\s*=\s*\{([^}]*)\};\s*\n\s*name\s*=\s*([^;]+)\s*;"#
        let regex = try NSRegularExpression(pattern: pattern, options: [])
        let nsRange = NSRange(content.startIndex..., in: content)

        var results: [ParsedConfiguration] = []
        regex.enumerateMatches(in: content, options: [], range: nsRange) { match, _, _ in
            guard let match, match.numberOfRanges >= 6 else { return }

            let configName = content[Range(match.range(at: 5), in: content)!].trimmingCharacters(in: .whitespacesAndNewlines)
            let buildSettingsContent = content[Range(match.range(at: 4), in: content)!].trimmingCharacters(in: .whitespacesAndNewlines)

            let settings = buildSettingsContent
                .components(separatedBy: ";")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }

            results.append(ParsedConfiguration(
                name: configName,
                hasBaseConfiguration: true,
                buildSettings: settings,
            ))
        }

        // Also find configs without baseConfigurationReference
        let noConfigPattern = #"isa\s*=\s*XCBuildConfiguration;\s*\n(\s*buildSettings\s*=\s*\{([^}]*)\};\s*\n\s*name\s*=\s*([^;]+)\s*;)"#
        let noConfigRegex = try NSRegularExpression(pattern: noConfigPattern, options: [])
        noConfigRegex.enumerateMatches(in: content, options: [], range: nsRange) { match, _, _ in
            guard let match, match.numberOfRanges >= 4 else { return }

            let configName = content[Range(match.range(at: 3), in: content)!].trimmingCharacters(in: .whitespacesAndNewlines)
            let buildSettingsContent = content[Range(match.range(at: 2), in: content)!].trimmingCharacters(in: .whitespacesAndNewlines)

            let settings = buildSettingsContent
                .components(separatedBy: ";")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }

            // Only add if not already found (has baseConfigurationReference)
            if !results.contains(where: { $0.name == configName }) {
                results.append(ParsedConfiguration(
                    name: configName,
                    hasBaseConfiguration: false,
                    buildSettings: settings,
                ))
            }
        }

        return results
    }

    private struct ParsedConfiguration {
        let name: String
        let hasBaseConfiguration: Bool
        let buildSettings: [String]
    }
}
