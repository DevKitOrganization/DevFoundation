// swift-tools-version: 6.0

import PackageDescription


let package = Package(
    name: "DevFoundation",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
        .tvOS(.v18),
        .visionOS(.v2),
        .watchOS(.v8),
    ],
    products: [
        .library(
            name: "DevFoundation",
            targets: ["DevFoundation"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/prachigauriar/DevTesting", from: "1.0.0-beta.4"),
        .package(url: "https://github.com/prachigauriar/URLMock.git", from: "1.3.6"),
    ],
    targets: [
        .target(
            name: "DevFoundation",
            swiftSettings: [
                .enableUpcomingFeature("ExistentialAny")
            ]
        ),
        .testTarget(
            name: "DevFoundationTests",
            dependencies: [
                "DevFoundation",
                "DevTesting",
                "URLMock",
            ],
            swiftSettings: [
                .enableUpcomingFeature("ExistentialAny")
            ]
        ),
    ]
)
