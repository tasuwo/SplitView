// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SplitView",
    platforms: [
        .iOS("16"), .macOS(.v12),
    ],
    products: [
        .library(
            name: "SplitView",
            targets: ["SplitView"]
        )
    ],
    targets: [
        .target(name: "SplitView")
    ]
)
