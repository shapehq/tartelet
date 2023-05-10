import LogConsumer
import OSLog

public struct LogConsumerOSLog: LogConsumer {
    private let log: OSLog

    public init(category: String) {
        log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: category)
    }

    public func info(_ message: StaticString, _ args: CVarArg...) {
        log(.info, message, args)
    }

    public func debug(_ message: StaticString, _ args: CVarArg...) {
        log(.debug, message, args)
    }

    public func error(_ message: StaticString, _ args: CVarArg...) {
        log(.error, message, args)
    }

    public func fault(_ message: StaticString, _ args: CVarArg...) {
        log(.fault, message, args)
    }
}

private extension LogConsumerOSLog {
    private func log(_ logLevel: OSLogType, _ message: StaticString, _ args: CVarArg...) {
        switch args.count {
        case 1:
            os_log(logLevel, log: log, message, args[0])
        case 2:
            os_log(logLevel, log: log, message, args[0], args[1])
        case 3:
            os_log(logLevel, log: log, message, args[0], args[1], args[2])
        case 4:
            os_log(logLevel, log: log, message, args[0], args[1], args[2], args[3])
        case 5:
            os_log(logLevel, log: log, message, args[0], args[1], args[2], args[3], args[4])
        default:
            os_log(logLevel, log: log, message)
        }
    }
}
