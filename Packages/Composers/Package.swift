// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "Composers",
    platforms: [.macOS(.v14)],
    products: [
        .library(
            name: "Composers",
            targets: ["Composers"]),
    ],
    dependencies: [
        .package(path: "../FileSystem"),
        .package(path: "../GitHub"),
        .package(path: "../Keychain"),
        .package(path: "../Logging"),
        .package(path: "../MenuBar"),
        .package(path: "../Networking"),
        .package(path: "../Settings"),
        .package(path: "../Shell"),
        .package(path: "../SSH"),
        .package(path: "../VirtualMachine"),
    ],
    targets: [
        .target(
            name: "Composers",
            dependencies: [
                .product(name: "FileSystemData", package: "FileSystem"),
                .product(name: "GitHubData", package: "GitHub"),
                .product(name: "GitHubDomain", package: "GitHub"),
                "Keychain",
                .product(name: "LoggingData", package: "Logging"),
                .product(name: "LoggingDomain", package: "Logging"),
                "MenuBar",
                .product(name: "NetworkingData", package: "Networking"),
                .product(name: "SettingsData", package: "Settings"),
                .product(name: "ShellData", package: "Shell"),
                .product(name: "SSHData", package: "SSH"),
                .product(name: "VirtualMachineData", package: "VirtualMachine"),
                .product(name: "VirtualMachineDomain", package: "VirtualMachine"),
            ]
        ),
    ]
)
