// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MenuBar",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "MenuBarItem", targets: ["MenuBarItem"])
    ],
    dependencies: [
        .package(path: "../Settings"),
        .package(path: "../VirtualMachine")
    ],
    targets: [
        .target(name: "MenuBarItem", dependencies: [
            .product(name: "SettingsStore", package: "Settings"),
            .product(name: "VirtualMachineEditorService", package: "VirtualMachine"),
            .product(name: "VirtualMachineFleet", package: "VirtualMachine")
        ], resources: [.process("Supporting files/Localizable.strings")])
    ]
)
