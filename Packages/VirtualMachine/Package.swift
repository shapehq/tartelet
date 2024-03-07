// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VirtualMachine",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "VirtualMachineData", targets: [
            "VirtualMachineData"
        ]),
        .library(name: "VirtualMachineDomain", targets: [
            "VirtualMachineDomain"
        ])
    ],
    dependencies: [
        .package(path: "../Logging"),
        .package(path: "../Shell")
    ],
    targets: [
        .target(name: "VirtualMachineData", dependencies: [
            "VirtualMachineDomain",
            .product(name: "LoggingDomain", package: "Logging"),
            .product(name: "Shell", package: "Shell")
        ]),
        .target(name: "VirtualMachineDomain", dependencies: [
            .product(name: "LoggingDomain", package: "Logging")
        ])
    ]
)
