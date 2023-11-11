// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SplitView",
    platforms: [
        .iOS("16"), .macOS(.v12)
    ],
    products: [
        .library(
            name: "SplitView",
            targets: ["SplitView"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-format", .upToNextMajor(from: "509.0.0"))
    ],
    targets: [
        .target(name: "SplitView")
    ]
)
