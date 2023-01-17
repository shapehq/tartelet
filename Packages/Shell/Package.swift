// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Shell",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "Shell", targets: ["Shell"])
    ],
    targets: [
        .target(name: "Shell")
    ]
)
