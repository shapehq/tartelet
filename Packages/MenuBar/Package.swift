// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MenuBar",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "MenuBar", targets: [
            "MenuBar"
        ])
    ],
    dependencies: [
        .package(path: "../Settings"),
        .package(path: "../VirtualMachine")
    ],
    targets: [
        .target(name: "MenuBar", dependencies: [
            .product(name: "SettingsDomain", package: "Settings"),
            .product(name: "VirtualMachineDomain", package: "VirtualMachine")
        ], resources: [.process("Internal/Localizable.strings")])
    ]
)
