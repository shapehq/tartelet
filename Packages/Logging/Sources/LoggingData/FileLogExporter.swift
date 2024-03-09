import AppKit
import FileSystemDomain
import LoggingDomain

public struct FileLogExporter: LogExporter {
    private let logger: Logger
    private let fileSystem: FileSystem

    public init(logger: Logger, fileSystem: FileSystem) {
        self.logger = logger
        self.fileSystem = fileSystem
    }

    public func export() {
        do {
            let logsDirectory = LogsDirectory(fileSystem: fileSystem)
            try fileSystem.createDirectoryIfNeeded(at: logsDirectory.url)
            NSWorkspace.shared.open(logsDirectory.url)
        } catch {
            logger.error("Failed exporting logs: \(error.localizedDescription)")
        }
    }
}
