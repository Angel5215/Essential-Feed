//
// SceneDelegateTests.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

@testable import EssentialAppCaseStudy
import EssentialFeedMobile
import XCTest

@MainActor
final class SceneDelegateTests: XCTestCase {
    func test_configureWindow_configuresRootViewController() throws {
        let sut = SceneDelegate()
        sut.window = try UIWindowSpy.make()

        sut.configureWindow()

        let root = sut.window?.rootViewController
        let rootNavigation = root as? UINavigationController
        let topController = rootNavigation?.topViewController

        XCTAssertNotNil(rootNavigation, "Expected a navigation controller as root, got \(String(describing: root)) instead.")
        XCTAssertTrue(topController is ListViewController, "Expected a feed controller as top view controller, got \(String(describing: topController)) instead")
    }

    func test_configureWindow_setsUpWindowAsKeyAndVisible() throws {
        let window = try UIWindowSpy.make()
        let sut = SceneDelegate()
        sut.window = window

        sut.configureWindow()

        XCTAssertEqual(window.makeKeyAndVisibleCallCount, 1)
    }

    // MARK: - Helpers

    private final class UIWindowSpy: UIWindow {
        private(set) var makeKeyAndVisibleCallCount = 0

        static func make(file: StaticString = #filePath, line: UInt = #line) throws -> UIWindowSpy {
            let dummyScene = try XCTUnwrap((UIWindowScene.self as NSObject.Type).init() as? UIWindowScene, "Unable to create WindowScene", file: file, line: line)
            return UIWindowSpy(windowScene: dummyScene)
        }

        override func makeKeyAndVisible() {
            makeKeyAndVisibleCallCount += 1
        }
    }
}
