import Shell

public struct Tart {
    private let shell: Shell

    public init(shell: Shell) {
        self.shell = shell
    }

    public func clone(sourceName: String, newName: String) async throws {
        try await executeCommand(withArguments: ["clone", sourceName, newName])
    }

    public func run(name: String, mounting directories: [Directory] = []) async throws {
        let mountArgs = directories.map { "--dir=\($0.name):\($0.directoryURL.path)" }
        let args = ["run"] + mountArgs + [name]
        try await executeCommand(withArguments: args)
    }

    public func delete(name: String) async throws {
        try await executeCommand(withArguments: ["delete", name])
    }

    public func list() async throws -> [String] {
        let result = try await executeCommand(withArguments: ["list", "-q", "--source", "local"])
        return result.split(separator: "\n").map(String.init)
    }
}

private extension Tart {
    @discardableResult
    private func executeCommand(withArguments arguments: [String]) async throws -> String {
        let locator = TartLocator(shell: shell)
        let filePath = try locator.locate()
        return try await shell.runExecutable(atPath: filePath, withArguments: arguments)
    }
}
