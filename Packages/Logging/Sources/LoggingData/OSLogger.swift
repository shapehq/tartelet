import Foundation
import LoggingDomain
import os

public struct OSLogger: LoggingDomain.Logger {
    private let logger: os.Logger

    public init(subsystem: String, category: String = Bundle.main.bundleIdentifier!) {
        self.logger = os.Logger(subsystem: subsystem, category: category)
    }

    public func info(_ message: String) {
        logger.info("\(message, privacy: .public)")
    }

    public func error(_ message: String) {
        logger.error("\(message, privacy: .public)")
    }
}
