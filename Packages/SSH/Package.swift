// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SSH",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "SSHData", targets: [
            "SSHData"
        ]),
        .library(name: "SSHDomain", targets: [
            "SSHDomain"
        ])
    ],
    dependencies: [
        .package(path: "../Logging"),
        .package(url: "https://github.com/orlandos-nl/Citadel", .upToNextMinor(from: "0.7.0"))
    ],
    targets: [
        .target(name: "SSHData", dependencies: [
            "SSHDomain",
            "Citadel",
            .product(name: "LoggingDomain", package: "Logging")
        ]),
        .target(name: "SSHDomain")
    ]
)
