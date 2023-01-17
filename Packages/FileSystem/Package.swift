// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FileSystem",
    products: [
        .library(name: "FileSystem", targets: ["FileSystem"]),
        .library(name: "FileSystemDisk", targets: ["FileSystemDisk"])
    ],
    targets: [
        .target(name: "FileSystem"),
        .target(name: "FileSystemDisk", dependencies: [
            "FileSystem"
        ])
    ]
)
