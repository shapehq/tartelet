import Foundation

public protocol FileSystem {
    var applicationSupportDirectoryURL: URL { get }
    func createDirectoryIfNeeded(at directoryURL: URL) throws
    func removeItem(at itemURL: URL) throws
    func copyItem(from sourceItemURL: URL, to destinationItemURL: URL) throws
    func contentsOfDirectory(at directoryURL: URL) throws -> [URL]
    func itemExists(at directoryURL: URL) -> Bool
}
