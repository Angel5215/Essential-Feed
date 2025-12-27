// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "InternalDependencies",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
    ],
    products: [
        .singleTargetLibrary(named: "EssentialFeed"),
    ],
    targets: [
        .target(
            name: "EssentialFeed",
        ),
        .testTarget(
            name: "EssentialFeedTests",
            dependencies: ["EssentialFeed"],
        ),
        .testTarget(
            name: "EssentialFeedAPIEndToEndTests",
            dependencies: ["EssentialFeed"],
        ),
        .testTarget(
            name: "EssentialFeedCacheIntegrationTests",
            dependencies: ["EssentialFeed"],
        ),
    ],
)

extension Product {
    static func singleTargetLibrary(named name: String) -> Product {
        .library(name: name, targets: [name])
    }
}
