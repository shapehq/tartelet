// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FileSystem",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "FileSystemData", targets: [
            "FileSystemData"
        ]),
        .library(name: "FileSystemDomain", targets: [
            "FileSystemDomain"
        ])
    ],
    targets: [
        .target(name: "FileSystemData", dependencies: [
            "FileSystemDomain"
        ]),
        .target(name: "FileSystemDomain")
    ]
)
