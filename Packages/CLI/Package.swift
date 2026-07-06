// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "tartelet",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
        .package(path: "../Composers"),
        .package(path: "../Settings"),
        .package(path: "../Shell"),
        .package(path: "../VirtualMachine"),
    ],
    targets: [
        .executableTarget(
            name: "tartelet",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "Composers",
                .product(name: "SettingsData", package: "Settings"),
                .product(name: "SettingsDomain", package: "Settings"),
                .product(name: "ShellData", package: "Shell"),
                .product(name: "VirtualMachineData", package: "VirtualMachine"),
            ]
        ),
    ]
)
