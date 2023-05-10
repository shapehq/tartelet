import OSLog

enum LogEntryFormatter {
    static func format(_ entry: OSLogEntryLog) -> String {
        [
            entry.date.formatted(.iso8601),
            "[\(entry.category)]",
            "[\(entry.level.stringValue)]",
            entry.composedMessage
        ].joined(separator: " ")
    }
}

private extension OSLogEntryLog.Level {
    var stringValue: String {
        switch self {
        case .undefined:
            return "Undefined"
        case .debug:
            return "Debug"
        case .info:
            return "Info"
        case .notice:
            return "Notice"
        case .error:
            return "Error"
        case .fault:
            return "Fault"
        @unknown default:
            return "Unknown"
        }
    }
}
