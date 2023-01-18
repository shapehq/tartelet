// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VirtualMachine",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "VirtualMachine", targets: ["VirtualMachine"]),
        .library(name: "VirtualMachineEditorService", targets: ["VirtualMachineEditorService"]),
        .library(name: "VirtualMachineFactory", targets: ["VirtualMachineFactory"]),
        .library(name: "VirtualMachineFleet", targets: ["VirtualMachineFleet"]),
        .library(name: "VirtualMachineFleetFactory", targets: ["VirtualMachineFleetFactory"]),
        .library(name: "VirtualMachineFleetService", targets: ["VirtualMachineFleetService"]),
        .library(name: "VirtualMachineResourcesService", targets: ["VirtualMachineResourcesService"]),
        .library(name: "VirtualMachineResourcesServiceEditor", targets: ["VirtualMachineResourcesServiceEditor"]),
        .library(name: "VirtualMachineResourcesServiceFleet", targets: ["VirtualMachineResourcesServiceFleet"]),
        .library(name: "VirtualMachineSourceNameRepository", targets: ["VirtualMachineSourceNameRepository"])
    ],
    dependencies: [
        .package(path: "../FileSystem")
    ],
    targets: [
        .target(name: "VirtualMachine"),
        .target(name: "VirtualMachineEditorService", dependencies: [
            "VirtualMachine",
            "VirtualMachineFactory",
            "VirtualMachineResourcesService"
        ]),
        .target(name: "VirtualMachineFactory", dependencies: [
            "VirtualMachine"
        ]),
        .target(name: "VirtualMachineFleet", dependencies: [
            "VirtualMachine",
            "VirtualMachineFactory"
        ]),
        .target(name: "VirtualMachineFleetFactory", dependencies: [
            "VirtualMachineFleet"
        ]),
        .target(name: "VirtualMachineFleetService", dependencies: [
            "VirtualMachineFleetFactory",
            "VirtualMachineResourcesService"
        ]),
        .target(name: "VirtualMachineResourcesService"),
        .target(name: "VirtualMachineResourcesServiceEditor", dependencies: [
            "VirtualMachineResourcesService",
            .product(name: "FileSystem", package: "FileSystem")
        ], resources: [.copy("Resources")]),
        .target(name: "VirtualMachineResourcesServiceFleet", dependencies: [
            "VirtualMachineResourcesService",
            .product(name: "FileSystem", package: "FileSystem")
        ]),
        .target(name: "VirtualMachineSourceNameRepository")
    ]
)
