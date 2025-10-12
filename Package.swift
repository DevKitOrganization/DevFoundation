// swift-tools-version: 6.2

import CompilerPluginSupport
import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("MemberImportVisibility"),
]

let package = Package(
    name: "DevFoundation",
    platforms: [
        .iOS(.v26),
        .macOS(.v26),
        .tvOS(.v26),
        .visionOS(.v26),
        .watchOS(.v26),
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
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.6.1"),
        .package(url: "https://github.com/apple/swift-numerics.git", from: "1.1.0"),
        .package(url: "https://github.com/apple/swift-syntax.git", from: "602.0.0"),
        .package(url: "https://github.com/DevKitOrganization/DevTesting", from: "1.3.0"),
        .package(url: "https://github.com/prachigauriar/URLMock.git", from: "1.3.6"),
    ],
    targets: [
        .macro(
            name: "DevFoundationMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "DevFoundation",
            dependencies: ["DevFoundationMacros"],
            swiftSettings: swiftSettings,
        ),
        .testTarget(
            name: "DevFoundationTests",
            dependencies: [
                "DevFoundation",
                "DevTesting",
                .product(name: "RealModule", package: "swift-numerics"),
                "URLMock",
            ],
            swiftSettings: swiftSettings
        ),

        .executableTarget(
            name: "dfob",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "DevFoundation",
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "dfobTests",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "DevFoundation",
                "DevTesting",
                "dfob",
            ],
            swiftSettings: swiftSettings
        ),
    ]
)
