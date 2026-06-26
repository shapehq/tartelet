import Foundation
import ShellDomain

public struct Tart {
    private let homeProvider: TartHomeProvider
    private let shell: Shell

    public init(homeProvider: TartHomeProvider, shell: Shell) {
        self.homeProvider = homeProvider
        self.shell = shell
    }

    public func clone(sourceName: String, newName: String) async throws {
        try await executeCommand(withArguments: ["clone", sourceName, newName])
    }

    public func run(name: String) async throws {
        let homeFolderURL = homeProvider.homeFolderURL ??
            FileManager.default.homeDirectoryForCurrentUser.appending(component: ".tart")
        let cacheFolder = homeFolderURL.appendingPathComponent("cache")
        if !FileManager.default.fileExists(atPath: cacheFolder.path) {
            try FileManager.default.createDirectory(atPath: cacheFolder.path, withIntermediateDirectories: true)
        }
        var runArgs =  ["run", "--dir=cache:\(cacheFolder.path())"]
        if let tartRunOptions = ProcessInfo.processInfo.environment["TARTELET_RUN_OPTIONS"] {
            runArgs.append(tartRunOptions)
        }
        runArgs.append(name)
        try await executeCommand(withArguments: runArgs)
    }

    public func delete(name: String) async throws {
        try await executeCommand(withArguments: ["delete", name])
    }

    public func list() async throws -> [String] {
        let result = try await executeCommand(withArguments: ["list", "-q", "--source", "local"])
        return result.split(separator: "\n").map(String.init)
    }

    public func getIPAddress(ofVirtualMachineNamed name: String) async throws -> String {
        let result = try await executeCommand(withArguments: ["ip", name])
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

private extension Tart {
    @discardableResult
    private func executeCommand(withArguments arguments: [String]) async throws -> String {
        let filePath = try TartLocator(shell: shell).locate()
        return try await shell.runExecutable(
            atPath: filePath,
            withArguments: arguments,
            environment: environment(forTartAt: filePath)
        )
    }

    private func environment(forTartAt tartPath: String) -> [String: String] {
        // Inherit the launching process's environment instead of replacing it.
        // Spawning tart with an empty (or TART_HOME-only) environment left it
        // without a usable PATH, so it could not find helpers it execs by name.
        var environment = ProcessInfo.processInfo.environment
        if let homeFolderURL = homeProvider.homeFolderURL {
            environment["TART_HOME"] = homeFolderURL.path(percentEncoded: false)
        }
        // tart execs helper binaries (e.g. `softnet` for `--net-softnet`) by name,
        // resolving them through PATH. They are installed alongside the tart binary,
        // so ensure tart's own directory is on PATH. This matters when Tartelet runs
        // as a GUI app, whose launchd PATH omits e.g. the Homebrew bin directory.
        let tartDirectory = (tartPath as NSString).deletingLastPathComponent
        if let existingPath = environment["PATH"], !existingPath.isEmpty {
            environment["PATH"] = tartDirectory + ":" + existingPath
        } else {
            environment["PATH"] = tartDirectory
        }
        return environment
    }
}
