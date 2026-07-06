import Foundation
import ShellDomain

public struct Tart {
    private let homeProvider: TartHomeProvider
    private let shell: Shell
    private var environment: [String: String]? {
        guard let homeFolderURL = homeProvider.homeFolderURL else {
            return nil
        }
        return ["TART_HOME": homeFolderURL.path(percentEncoded: false)]
    }

    public init(homeProvider: TartHomeProvider, shell: Shell) {
        self.homeProvider = homeProvider
        self.shell = shell
    }

    public func clone(sourceName: String, newName: String) async throws {
        try await executeCommand(withArguments: ["clone", sourceName, newName])
    }

    public func run(name: String) async throws {
        try await executeCommand(withArguments: runArguments(name: name))
    }

    public func runDetached(name: String) throws {
        let locator = TartLocator(shell: shell)
        let filePath = try locator.locate()
        let process = Process()
        process.executableURL = URL(fileURLWithPath: filePath)
        process.arguments = try runArguments(name: name)
        if let environment {
            process.environment = environment
        }

        let nullDevice = FileHandle(forWritingAtPath: "/dev/null")
        process.standardInput = nil
        process.standardOutput = nullDevice
        process.standardError = nullDevice

        try process.run()
    }

    public func delete(name: String) async throws {
        try await executeCommand(withArguments: ["delete", name])
    }

    public func stop(name: String) async throws {
        try await executeCommand(withArguments: ["stop", name])
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
    private func runArguments(name: String) throws -> [String] {
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
        return runArgs
    }

    @discardableResult
    private func executeCommand(withArguments arguments: [String]) async throws -> String {
        let locator = TartLocator(shell: shell)
        let filePath = try locator.locate()
        if let environment {
            return try await shell.runExecutable(
                atPath: filePath,
                withArguments: arguments,
                environment: environment
            )
        } else {
            return try await shell.runExecutable(
                atPath: filePath,
                withArguments: arguments
            )
        }
    }
}
