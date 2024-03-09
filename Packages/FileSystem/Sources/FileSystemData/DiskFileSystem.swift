import FileSystemDomain
import Foundation

public final class DiskFileSystem: FileSystem {
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
        try NSFileCoordinator.coordinateReadingItem(
            at: sourceItemURL,
            writingTo: destinationItemURL
        ) { safeReadingFileURL, safeWritingFileURL in
            try fileManager.copyItem(at: safeReadingFileURL, to: safeWritingFileURL)
        }
    }

    public func contentsOfDirectory(at directoryURL: URL) throws -> [URL] {
        try fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
    }

    public func itemExists(at directoryURL: URL) -> Bool {
        fileManager.fileExists(atPath: directoryURL.path)
    }

    public func write(_ data: Data, toFileAt fileURL: URL) throws {
        try NSFileCoordinator.coordinateWritingItem(at: fileURL, options: .forReplacing) { safeFileURL in
            try data.write(to: safeFileURL, options: .atomic)
        }
    }

    public func append(_ data: Data, toFileAt fileURL: URL) throws {
        try NSFileCoordinator.coordinateWritingItem(at: fileURL, options: .forReplacing) { safeFileURL in
            if let fileHandle = FileHandle(forWritingAtPath: safeFileURL.path) {
                defer {
                    fileHandle.closeFile()
                }
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
            } else {
                try data.write(to: safeFileURL, options: .atomic)
            }
        }
    }
}
