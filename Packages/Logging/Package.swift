// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Logging",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "LoggingDomain", targets: [
            "LoggingDomain"
        ]),
        .library(name: "LoggingData", targets: [
            "LoggingData"
        ])
    ],
    dependencies: [
        .package(path: "../FileSystem")
    ],
    targets: [
        .target(name: "LoggingData", dependencies: [
            "LoggingDomain",
            .product(name: "FileSystemDomain", package: "FileSystem")
        ]),
        .target(name: "LoggingDomain")
    ]
)
