// swift-tools-version: 6.0

import PackageDescription


let package = Package(
    name: "DevFoundation",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
        .tvOS(.v18),
        .visionOS(.v2),
        .watchOS(.v11),
    ],
    products: [
        .library(
            name: "DevFoundation",
            targets: ["DevFoundation"]
        ),
        .executable(
            name: "dfob",
            targets: [
                "DevFoundation",
                "dfob",
            ]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.5.0"),
        .package(url: "https://github.com/prachigauriar/DevTesting", from: "1.0.0-beta.5"),
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

        .executableTarget(
            name: "dfob",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "DevFoundation",
            ],
            swiftSettings: [
                .enableUpcomingFeature("ExistentialAny")
            ]
        ),
        .testTarget(
            name: "dfobTests",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "DevFoundation",
                "DevTesting",
                "dfob",
            ],
            swiftSettings: [
                .enableUpcomingFeature("ExistentialAny")
            ]
        ),
    ]
)
