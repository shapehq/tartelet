import FileSystem
import Foundation
import LogHelpers
import OSLog

public struct VirtualMachineResourcesCopier {
    private let logger = Logger(category: "VirtualMachineResourcesCopier")
    private let fileSystem: FileSystem

    public init(fileSystem: FileSystem) {
        self.fileSystem = fileSystem
    }

    public func copyResources(from sourceDirectoryURL: URL, to destinationDirectoryURL: URL) throws {
        let sourceFileURLs = try fileSystem.contentsOfDirectory(at: sourceDirectoryURL)
        for sourceFileURL in sourceFileURLs {
            let destinationFileURL = destinationDirectoryURL.appending(path: sourceFileURL.lastPathComponent)
            try copySingleResource(from: sourceFileURL, to: destinationFileURL)
        }
    }

    public func copySingleResource(from sourceFileURL: URL, to destinationFileURL: URL) throws {
        do {
            if fileSystem.itemExists(at: destinationFileURL) {
                try fileSystem.removeItem(at: destinationFileURL)
            }
        } catch {
            // Log the error but don't rethrow it as it is not severe.
            // swiftlint:disable:next line_length
            logger.info("Failed removing resources at \(destinationFileURL.absoluteString, privacy: .public): \(error.localizedDescription, privacy: .public)")
        }
        do {
            try fileSystem.copyItem(from: sourceFileURL, to: destinationFileURL)
        } catch {
            // swiftlint:disable:next line_length
            logger.info("Failed copying resources from \(sourceFileURL.absoluteString, privacy: .public) to \(destinationFileURL.absoluteString, privacy: .public): \(error.localizedDescription, privacy: .public)")
            throw error
        }
    }
}
