// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Settings",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "SettingsData", targets: [
            "SettingsData"
        ]),
        .library(name: "SettingsDomain", targets: [
            "SettingsDomain"
        ]),
        .library(name: "SettingsUI", targets: [
            "SettingsUI"
        ])
    ],
    dependencies: [
        .package(path: "../GitHub"),
        .package(path: "../Logging"),
        .package(path: "../VirtualMachine")
    ],
    targets: [
        .target(name: "SettingsData", dependencies: [
            "SettingsDomain"
        ]),
        .target(name: "SettingsDomain", dependencies: [
            .product(name: "GitHubDomain", package: "GitHub")
        ]),
        .target(name: "SettingsUI", dependencies: [
            "SettingsDomain",
            .product(name: "GitHubDomain", package: "GitHub"),
            .product(name: "LoggingDomain", package: "Logging"),
            .product(name: "VirtualMachineDomain", package: "VirtualMachine")
        ], resources: [.process("Internal/Localizable.strings")])
    ]
)
