// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Networking",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "NetworkingData", targets: [
            "NetworkingData"
        ]),
        .library(name: "NetworkingDomain", targets: [
            "NetworkingDomain"
        ])
    ],
    dependencies: [
        .package(path: "../Logging")
    ],
    targets: [
        .target(name: "NetworkingData", dependencies: [
            .product(name: "LoggingDomain", package: "Logging"),
            "NetworkingDomain"
        ]),
        .target(name: "NetworkingDomain")
    ]
)
