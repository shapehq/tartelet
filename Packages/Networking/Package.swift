// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Networking",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "NetworkingService", targets: ["NetworkingService"]),
        .library(name: "NetworkingServiceLive", targets: ["NetworkingServiceLive"])
    ],
    dependencies: [
        .package(path: "../Logging")
    ],
    targets: [
        .target(name: "NetworkingService"),
        .target(name: "NetworkingServiceLive", dependencies: [
            .product(name: "LogHelpers", package: "Logging"),
            "NetworkingService"
        ])
    ]
)
