// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VirtualMachineAutomaticLauncher",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "VirtualMachineAutomaticLauncher", targets: ["VirtualMachineAutomaticLauncher"])
    ],
    dependencies: [
        .package(path: "../Logging"),
        .package(path: "../Settings"),
        .package(path: "../VirtualMachine")
    ],
    targets: [
        .target(name: "VirtualMachineAutomaticLauncher", dependencies: [
            .product(name: "LogHelpers", package: "Logging"),
            .product(name: "SettingsStore", package: "Settings"),
            .product(name: "VirtualMachineFleet", package: "VirtualMachine")
        ]),
        .testTarget(name: "VirtualMachineAutomaticLauncherTests", dependencies: [
            .product(name: "LogHelpers", package: "Logging"),
            .product(name: "SettingsStore", package: "Settings"),
            "VirtualMachineAutomaticLauncher",
            .product(name: "VirtualMachineFleet", package: "VirtualMachine")
        ])
    ]
)
