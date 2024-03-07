import Foundation
import LoggingDomain

public struct NullObjectLogExporter: LogExporter {
    public init() {}

    public func export() async throws -> URL {
        fatalError("Not implemented")
    }
}
