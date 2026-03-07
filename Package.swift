// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SwiftCommons",
    platforms: [
        .macOS(.v10_13),
        .iOS(.v15),
        .visionOS(.v1),
        .watchOS(.v9),
        .tvOS(.v16),
    ],
    products: [
        .library(
            name: "SCInject",
            targets: ["SCInject"]
        ),
    ],
    targets: [
        .target(
            name: "SCInject",
            dependencies: [
                .target(name: "SCInjectObjc"),
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6),
            ]
        ),
        .target(
            name: "SCInjectObjc",
            dependencies: [],
            swiftSettings: [
                .swiftLanguageMode(.v6),
            ]
        ),
        .testTarget(
            name: "SCInjectTests",
            dependencies: ["SCInject"],
            swiftSettings: [
                .swiftLanguageMode(.v6),
            ]
        ),
    ]
)
