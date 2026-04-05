// swift-tools-version: 6.3
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
        .singleTargetLibrary(named: "EssentialFeedMobile"),
    ],
    targets: [
        .target(
            name: "EssentialFeed",
            swiftSettings: .with(
                settings: [
                    .strictConcurrency,
                    .approachableConcurrency,
                ]
            ),
        ),
        .target(
            name: "EssentialFeedMobile",
            dependencies: ["EssentialFeed"],
            swiftSettings: .with(
                settings: [
                    .strictConcurrency,
                    .approachableConcurrency,
                    .mainActorIsolation,
                ]
            ),
        ),
        .testTarget(
            name: "EssentialFeedTests",
            dependencies: ["EssentialFeed"],
            swiftSettings: .with(
                settings: [
                    .strictConcurrency,
                    .approachableConcurrency,
                ]
            ),
        ),
        .testTarget(
            name: "EssentialFeedAPIEndToEndTests",
            dependencies: ["EssentialFeed"],
            swiftSettings: .with(
                settings: [
                    .strictConcurrency,
                    .approachableConcurrency,
                ]
            ),
        ),
        .testTarget(
            name: "EssentialFeedCacheIntegrationTests",
            dependencies: ["EssentialFeed"],
            swiftSettings: .with(
                settings: [
                    .strictConcurrency,
                    .approachableConcurrency,
                ]
            ),
        ),
        .testTarget(
            name: "EssentialFeedMobileTests",
            dependencies: ["EssentialFeedMobile"],
            swiftSettings: .with(
                settings: [
                    .strictConcurrency,
                    .approachableConcurrency,
                ]
            ),
        ),
    ],
    swiftLanguageModes: [
        .v5
    ],
)

extension Product {
    static func singleTargetLibrary(named name: String) -> Product {
        .library(name: name, targets: [name])
    }
}

extension [SwiftSetting] {
    static func with(settings: [Self]) -> Self {
        settings.flatMap(\.self)
    }

    static var strictConcurrency: Self {
        [
            .unsafeFlags(["-Xfrontend", "-strict-concurrency=complete"]),
            .enableExperimentalFeature("StrictConcurrency", .when(platforms: [.macOS, .iOS])),
        ]
    }

    static var approachableConcurrency: Self {
        [
            .enableUpcomingFeature("DisableOutwardActorInference"),
            .enableUpcomingFeature("GlobalActorIsolatedTypesUsability"),
            .enableUpcomingFeature("InferIsolatedConformances"),
            .enableUpcomingFeature("InferSendableFromCaptures"),
            .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        ]
    }

    static var mainActorIsolation: Self {
        [
            .defaultIsolation(MainActor.self)
        ]
    }
}
