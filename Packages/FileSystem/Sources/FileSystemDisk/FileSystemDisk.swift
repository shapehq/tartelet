import FileSystem
import Foundation

public final class FileSystemDisk: FileSystem {
    public var applicationSupportDirectoryURL: URL {
        let baseDirectoryURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            return baseDirectoryURL.appending(path: bundleIdentifier, directoryHint: .isDirectory)
        } else {
            return baseDirectoryURL
        }
    }

    private let fileManager: FileManager = .default

    public init() {}

    public func createDirectoryIfNeeded(at directoryURL: URL) throws {
        var isDirectory: ObjCBool = false
        let fileExists = fileManager.fileExists(atPath: directoryURL.path, isDirectory: &isDirectory)
        if !fileExists || !isDirectory.boolValue {
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        }
    }

    public func removeItem(at itemURL: URL) throws {
        try fileManager.removeItem(at: itemURL)
    }

    public func copyItem(from sourceItemURL: URL, to destinationItemURL: URL) throws {
        try NSFileCoordinator.coordinateReadingItem(at: sourceItemURL, writingTo: destinationItemURL) { safeReadingFileURL, safeWritingFileURL in
            try fileManager.copyItem(at: safeReadingFileURL, to: safeWritingFileURL)
        }
    }

    public func contentsOfDirectory(at directoryURL: URL) throws -> [URL] {
        try fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
    }
}
