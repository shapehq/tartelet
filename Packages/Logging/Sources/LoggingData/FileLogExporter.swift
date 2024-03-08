import AppKit
import FileSystemDomain
import LoggingDomain

public struct FileLogExporter: LogExporter {
    private let fileSystem: FileSystem

    public init(fileSystem: FileSystem) {
        self.fileSystem = fileSystem
    }

    public func export() async throws {
        let logsDirectory = LogsDirectory(fileSystem: fileSystem)
        try fileSystem.createDirectoryIfNeeded(at: logsDirectory.url)
        NSWorkspace.shared.open(logsDirectory.url)
    }
}
