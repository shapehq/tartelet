// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GitHub",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "GitHubCredentialsStore", targets: ["GitHubCredentialsStore"]),
        .library(name: "GitHubCredentialsStoreKeychain", targets: ["GitHubCredentialsStoreKeychain"]),
        .library(name: "GitHubService", targets: ["GitHubService"]),
        .library(name: "GitHubServiceLive", targets: ["GitHubServiceLive"])
    ],
    dependencies: [
        .package(path: "../Keychain"),
        .package(path: "../Networking"),
        .package(url: "https://github.com/Kitura/Swift-JWT", from: "4.0.0")
    ],
    targets: [
        .target(name: "GitHubCredentialsStore"),
        .target(name: "GitHubCredentialsStoreKeychain", dependencies: [
            "GitHubCredentialsStore",
            .product(name: "Keychain", package: "Keychain")
        ]),
        .target(name: "GitHubJWTTokenFactory", dependencies: [
            .product(name: "SwiftJWT", package: "Swift-JWT")
        ]),
        .target(name: "GitHubService"),
        .target(name: "GitHubServiceLive", dependencies: [
            "GitHubService",
            "GitHubCredentialsStore",
            "GitHubJWTTokenFactory",
            .product(name: "NetworkingService", package: "Networking")
        ])
    ]
)
