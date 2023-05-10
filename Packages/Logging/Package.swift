// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Logging",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "LogConsumer", targets: ["LogConsumer"]),
        .library(name: "LogConsumerOSLog", targets: ["LogConsumerOSLog"]),
        .library(name: "LogExporter", targets: ["LogExporter"]),
        .library(name: "LogExporterLive", targets: ["LogExporterLive"]),
        .library(name: "LogStore", targets: ["LogStore"]),
        .library(name: "LogStoreOSLog", targets: ["LogStoreOSLog"])
    ],
    dependencies: [
        .package(path: "../FileSystem")
    ],
    targets: [
        .target(name: "LogConsumer"),
        .target(name: "LogConsumerOSLog", dependencies: [
            "LogConsumer"
        ]),
        .target(name: "LogExporter"),
        .target(name: "LogExporterLive", dependencies: [
            "FileSystem",
            "LogExporter",
            "LogStore"
        ]),
        .target(name: "LogStore"),
        .target(name: "LogStoreOSLog", dependencies: [
            "LogStore"
        ]),
        .testTarget(name: "LogExporterLiveTests", dependencies: [
            "FileSystem",
            "LogExporterLive",
            "LogStore"
        ])
    ]
)
