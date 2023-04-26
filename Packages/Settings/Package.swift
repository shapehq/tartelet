// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Settings",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "Settings", targets: ["Settings"]),
        .library(name: "SettingsStore", targets: ["SettingsStore"]),
        .library(name: "SettingsUI", targets: ["SettingsUI"])
    ],
    dependencies: [
        .package(path: "../GitHub"),
        .package(path: "../VirtualMachine")
    ],
    targets: [
        .target(name: "Settings"),
        .target(name: "SettingsStore", dependencies: [
            "Settings"
        ]),
        .target(name: "SettingsUI", dependencies: [
            .product(name: "GitHubCredentialsStore", package: "GitHub"),
            "Settings",
            "SettingsStore",
            .product(name: "VirtualMachineEditorService", package: "VirtualMachine"),
            .product(name: "VirtualMachineFleet", package: "VirtualMachine"),
            .product(name: "VirtualMachineSourceNameRepository", package: "VirtualMachine")
        ], resources: [.process("Supporting files/Localizable.strings")])
    ]
)
