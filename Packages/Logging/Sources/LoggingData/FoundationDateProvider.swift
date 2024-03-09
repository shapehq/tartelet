import Foundation
import LoggingDomain

public struct FoundationDateProvider: DateProvider {
    public init() {}

    public var now: Date {
        Date.now
    }
}
