// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TartVirtualMachine",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "EphemeralTartVirtualMachine", targets: ["EphemeralTartVirtualMachine"]),
        .library(name: "TartVirtualMachine", targets: ["TartVirtualMachine"]),
        .library(name: "TartVirtualMachineSourceNameRepository", targets: ["TartVirtualMachineSourceNameRepository"])
    ],
    dependencies: [
        .package(path: "../Tart"),
        .package(path: "../VirtualMachine")
    ],
    targets: [
        .target(name: "EphemeralTartVirtualMachine", dependencies: [
            "TartDirectoryHelpers",
            .product(name: "Tart", package: "Tart"),
            .product(name: "VirtualMachine", package: "VirtualMachine")
        ]),
        .target(name: "TartDirectoryHelpers", dependencies: [
            .product(name: "Tart", package: "Tart")
        ]),
        .target(name: "TartVirtualMachine", dependencies: [
            "TartDirectoryHelpers",
            .product(name: "Tart", package: "Tart"),
            .product(name: "VirtualMachine", package: "VirtualMachine")
        ]),
        .target(name: "TartVirtualMachineSourceNameRepository", dependencies: [
            .product(name: "Tart", package: "Tart"),
            .product(name: "VirtualMachineSourceNameRepository", package: "VirtualMachine")
        ])
    ]
)
