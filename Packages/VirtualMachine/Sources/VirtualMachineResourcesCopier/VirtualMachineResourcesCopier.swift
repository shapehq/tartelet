import FileSystem
import Foundation
import LogConsumer

public struct VirtualMachineResourcesCopier {
    private let logger: LogConsumer
    private let fileSystem: FileSystem

    public init(logger: LogConsumer, fileSystem: FileSystem) {
        self.logger = logger
        self.fileSystem = fileSystem
    }

    public func copyResources(from sourceDirectoryURL: URL, to destinationDirectoryURL: URL) throws {
        let sourceFileURLs = try fileSystem.contentsOfDirectory(at: sourceDirectoryURL)
        for sourceFileURL in sourceFileURLs {
            let destinationFileURL = destinationDirectoryURL.appending(path: sourceFileURL.lastPathComponent)
            do {
                try fileSystem.removeItem(at: destinationFileURL)
            } catch {
                // Log the error but don't rethrow it as it is not severe.
                logger.info("Failed removing resources at %@: %@", destinationFileURL.absoluteString, error.localizedDescription)
            }
            do {
                try fileSystem.copyItem(from: sourceFileURL, to: destinationFileURL)
            } catch {
                logger.info(
                    "Failed copying resources from %@ to %@: %@",
                    sourceFileURL.absoluteString,
                    destinationFileURL.absoluteString,
                    error.localizedDescription
                )
                throw error
            }
        }
    }
}
