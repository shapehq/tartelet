import FileSystem
import LogExporter
import LogStore
import OSLog

enum LogExporterLiveError: LocalizedError {
    case cannotCreateStringData

    var errorDescription: String? {
        switch self {
        case .cannotCreateStringData:
            return "Failed creating data to be written to disk"
        }
    }
}

public final actor LogExporterLive: LogExporter {
    private let logStore: LogStore
    private let fileSystem: FileSystem

    public init(fileSystem: FileSystem, logStore: LogStore) {
        self.fileSystem = fileSystem
        self.logStore = logStore
    }

    public func export() async throws -> URL {
        let messages = try logStore.readMessages()
        let filename = Bundle.main.bundleIdentifier! + ".log"
        let directoryURL = fileSystem.applicationSupportDirectoryURL
        let fileURL = directoryURL.appending(path: filename, directoryHint: .notDirectory)
        guard let data = messages.data(using: .utf8, allowLossyConversion: false) else {
            throw LogExporterLiveError.cannotCreateStringData
        }
        try fileSystem.createDirectoryIfNeeded(at: directoryURL)
        try fileSystem.write(data, toFileAt: fileURL)
        return fileURL
    }
}
