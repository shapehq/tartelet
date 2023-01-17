import Foundation

public protocol FileSystem {
    var applicationSupportDirectoryURL: URL { get }
    func createDirectoryIfNeeded(at directoryURL: URL) throws
}
