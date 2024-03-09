// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Keychain",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "Keychain", targets: [
            "Keychain"
        ])
    ],
    dependencies: [
        .package(path: "../Logging")
    ],
    targets: [
        .target(name: "Keychain", dependencies: [
            .product(name: "LoggingDomain", package: "Logging")
        ])
    ]
)
