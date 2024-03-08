import FileSystemDomain
import Foundation
import LoggingDomain

public final class FileLogger: LoggingDomain.Logger {
    private enum LogLevel: String {
        case info = "INFO"
        case error = "ERROR"
    }

    private let fileSystem: FileSystem
    private let dateProvider: DateProvider
    private let subsystem: String
    private let daysOfRetention: Int
    private var filenameDateFormatter = DateFormatter()
    private var logsDirectory: LogsDirectory {
        LogsDirectory(fileSystem: fileSystem)
    }
    private var latestLogsRemovalDate: Date?
    private var shouldRemoveOldLogs: Bool {
        guard let latestLogsRemovalDate else {
            return true
        }
        return latestLogsRemovalDate.timeIntervalSince(dateProvider.now) > 3_600
    }

    public init(
        fileSystem: FileSystem,
        dateProvider: DateProvider,
        subsystem: String,
        daysOfRetention: Int
    ) {
        self.fileSystem = fileSystem
        self.dateProvider = dateProvider
        self.subsystem = subsystem
        self.daysOfRetention = daysOfRetention
        filenameDateFormatter.dateFormat = "yyyy-MM-dd"
    }

    public func info(_ message: String) {
        try? append(.info, message: message)
    }

    public func error(_ message: String) {
        try? append(.info, message: message)
    }
}

private extension FileLogger {
    private func append(_ level: LogLevel, message: String) throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss.SSS"
        let timestamp = dateFormatter.string(from: dateProvider.now)
        let formattedMessage = "\(timestamp) \(level.rawValue): \(message)\n"
        guard let data = formattedMessage.data(using: .utf8) else {
            print("Failed creating data from log message")
            return
        }
        try fileSystem.createDirectoryIfNeeded(at: logsDirectory.url)
        let fileURL = getFileURL()
        if fileSystem.itemExists(at: fileURL) {
            try fileSystem.append(data, toFileAt: fileURL)
        } else {
            try fileSystem.write(data, toFileAt: fileURL)
        }
        if shouldRemoveOldLogs {
            try removeOldLogs()
            latestLogsRemovalDate = dateProvider.now
        }
    }

    private func getFileURL() -> URL {
        let filename = filenameDateFormatter.string(from: dateProvider.now) + ".txt"
        return logsDirectory.url.appending(path: filename, directoryHint: .notDirectory)
    }

    private func removeOldLogs() throws {
        let fileURLs = try fileSystem.contentsOfDirectory(at: logsDirectory.url)
        for fileURL in fileURLs {
            let filename = fileURL.lastPathComponent
            let stringDate = filename.split(separator: ".").dropLast().joined(separator: ".")
            guard let date = filenameDateFormatter.date(from: stringDate) else {
                continue
            }
            let elapsedSeconds = dateProvider.now.timeIntervalSince(date)
            let elapsedDays = elapsedSeconds / (24 * 3_600)
            print(elapsedDays)
            if elapsedDays >= Double(daysOfRetention) {
                print("Remove \(fileURL)")
            }
        }
    }
}
