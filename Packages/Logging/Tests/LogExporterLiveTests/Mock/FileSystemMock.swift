import FileSystem
import Foundation

final class FileSystemMock: FileSystem {
    private(set) var createdDirectoryURL: URL?
    private(set) var writtenData: Data?
    private(set) var writtenFileURL: URL?

    let applicationSupportDirectoryURL = URL(filePath: "/Mock/ApplicationSupport")

    func createDirectoryIfNeeded(at directoryURL: URL) throws {
        createdDirectoryURL = directoryURL
    }

    func removeItem(at itemURL: URL) throws {}

    func copyItem(from sourceItemURL: URL, to destinationItemURL: URL) throws {}

    func contentsOfDirectory(at directoryURL: URL) throws -> [URL] {
        []
    }

    func itemExists(at directoryURL: URL) -> Bool {
        false
    }

    func write(_ data: Data, toFileAt fileURL: URL) throws {
        writtenData = data
        writtenFileURL = fileURL
    }
}
