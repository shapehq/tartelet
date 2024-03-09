// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Shell",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "ShellData", targets: [
            "ShellData"
        ]),
        .library(name: "ShellDomain", targets: [
            "ShellDomain"
        ])
    ],
    targets: [
        .target(name: "ShellDomain"),
        .target(name: "ShellData", dependencies: [
            "ShellDomain"
        ])
    ]
)
