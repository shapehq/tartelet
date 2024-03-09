import Foundation

public struct GitHubAppAccessToken {
    public let rawValue: String

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }
}
