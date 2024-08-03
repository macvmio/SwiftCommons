// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "SwiftCommons",
    platforms: [
        .macOS(.v10_13),
        .iOS(.v15),
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
            dependencies: []
        ),
        .testTarget(
            name: "SCInjectTests",
            dependencies: ["SCInject"]
        ),
    ]
)
