// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VirtualMachine",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "VirtualMachineData", targets: [
            "VirtualMachineData"
        ]),
        .library(name: "VirtualMachineDomain", targets: [
            "VirtualMachineDomain"
        ])
    ],
    dependencies: [
        .package(path: "../GitHub"),
        .package(path: "../Keychain"),
        .package(path: "../Logging"),
        .package(path: "../Shell"),
        .package(path: "../SSH")
    ],
    targets: [
        .target(name: "VirtualMachineData", dependencies: [
            "VirtualMachineDomain",
            .product(name: "Keychain", package: "Keychain"),
            .product(name: "LoggingDomain", package: "Logging"),
            .product(name: "ShellDomain", package: "Shell")
        ]),
        .target(name: "VirtualMachineDomain", dependencies: [
            .product(name: "GitHubDomain", package: "GitHub"),
            .product(name: "LoggingDomain", package: "Logging"),
            .product(name: "SSHDomain", package: "SSH")
        ])
    ]
)
