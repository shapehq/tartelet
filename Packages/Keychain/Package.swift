// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Keychain",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "Keychain", targets: ["Keychain"]),
        .library(name: "KeychainLive", targets: ["KeychainLive"]),
        .library(name: "RSAPrivateKey", targets: ["RSAPrivateKey"])
    ],
    dependencies: [
        .package(path: "../Logging")
    ],
    targets: [
        .target(name: "Keychain", dependencies: [
            "RSAPrivateKey"
        ]),
        .target(name: "KeychainLive", dependencies: [
            "Keychain",
            .product(name: "LogHelpers", package: "Logging"),
            "RSAPrivateKey"
        ]),
        .target(name: "RSAPrivateKey")
    ]
)
