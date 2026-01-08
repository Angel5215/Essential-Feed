//
// SceneDelegateTests.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

@testable import EssentialAppCaseStudy
import EssentialFeedMobile
import XCTest

final class SceneDelegateTests: XCTestCase {
    func test_sceneWillConnectToSession_configuresRootViewController() throws {
        let sut = SceneDelegate()
        sut.window = try UIWindowSpy.make()

        sut.configureWindow()

        let root = sut.window?.rootViewController
        let rootNavigation = root as? UINavigationController
        let topController = rootNavigation?.topViewController

        XCTAssertNotNil(rootNavigation, "Expected a navigation controller as root, got \(String(describing: root)) instead.")
        XCTAssertTrue(topController is FeedViewController, "Expected a feed controller as top view controller, got \(String(describing: topController)) instead")
    }

    // MARK: - Helpers

    private final class UIWindowSpy: UIWindow {
        static func make(file: StaticString = #filePath, line: UInt = #line) throws -> UIWindowSpy {
            let dummyScene = try XCTUnwrap((UIWindowScene.self as NSObject.Type).init() as? UIWindowScene)
            return UIWindowSpy(windowScene: dummyScene)
        }

        override func makeKeyAndVisible() {}
    }
}
