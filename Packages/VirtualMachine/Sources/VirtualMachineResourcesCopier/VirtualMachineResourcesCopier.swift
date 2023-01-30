import FileSystem
import Foundation

public struct VirtualMachineResourcesCopier {
    private let fileSystem: FileSystem

    public init(fileSystem: FileSystem) {
        self.fileSystem = fileSystem
    }

    public func copyResources(from sourceDirectoryURL: URL, to destinationDirectoryURL: URL) throws {
        let sourceFileURLs = try fileSystem.contentsOfDirectory(at: sourceDirectoryURL)
        for sourceFileURL in sourceFileURLs {
            let destinationFileURL = destinationDirectoryURL.appending(path: sourceFileURL.lastPathComponent)
            try? fileSystem.removeItem(at: destinationFileURL)
            try fileSystem.copyItem(from: sourceFileURL, to: destinationFileURL)
        }
    }
}
