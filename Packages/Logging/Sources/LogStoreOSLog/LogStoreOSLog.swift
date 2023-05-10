import LogStore
import OSLog

public struct LogStoreOSLog: LogStore {
    public init() {}

    public func readMessages() throws -> String {
        let store = try OSLogStore(scope: .currentProcessIdentifier)
        return try store.getEntries()
            .compactMap { $0 as? OSLogEntryLog }
            .filter { $0.subsystem == Bundle.main.bundleIdentifier }
            .map(LogEntryFormatter.format)
            .joined(separator: "\n")
    }
}
