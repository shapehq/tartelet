// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Tart",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "Tart", targets: ["Tart"])
    ],
    dependencies: [
        .package(name: "Shell", path: "../Shell")
    ],
    targets: [
        .target(name: "Tart", dependencies: [
            .product(name: "Shell", package: "Shell")
        ])
    ]
)
