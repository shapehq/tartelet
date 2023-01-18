import FileSystem
import Foundation
import VirtualMachineResourcesService

public struct VirtualMachineResourcesServiceEditor: VirtualMachineResourcesService {
    public var directoryURL: URL {
        fileSystem
            .applicationSupportDirectoryURL
            .appending(path: "Virtual Machine Editor Resources", directoryHint: .isDirectory)
    }

    private let fileSystem: FileSystem

    public init(fileSystem: FileSystem) {
        self.fileSystem = fileSystem
    }

    public func createResourcesIfNeeded() throws {
        try fileSystem.createDirectoryIfNeeded(at: directoryURL)
        guard let resourcesDirectoryURL = Bundle.module.resourceURL?.appending(path: "Resources") else {
            return
        }
        let sourceFileURLs = try fileSystem.contentsOfDirectory(at: resourcesDirectoryURL)
        for sourceFileURL in sourceFileURLs {
            let destinationFileURL = directoryURL.appending(path: sourceFileURL.lastPathComponent)
            try? fileSystem.removeItem(at: destinationFileURL)
            try fileSystem.copyItem(from: sourceFileURL, to: destinationFileURL)
        }
    }
}
