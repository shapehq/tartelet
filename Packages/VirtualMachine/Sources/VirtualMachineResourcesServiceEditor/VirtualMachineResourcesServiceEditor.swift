import FileSystem
import Foundation
import VirtualMachineResourcesCopier
import VirtualMachineResourcesService

public struct VirtualMachineResourcesServiceEditor: VirtualMachineResourcesService {
    public var directoryURL: URL {
        fileSystem
            .applicationSupportDirectoryURL
            .appending(path: "Virtual Machine Resources", directoryHint: .isDirectory)
    }

    private let fileSystem: FileSystem
    private let resourcesCopier: VirtualMachineResourcesCopier

    public init(fileSystem: FileSystem, resourcesCopier: VirtualMachineResourcesCopier) {
        self.fileSystem = fileSystem
        self.resourcesCopier = resourcesCopier
    }

    public func createResourcesIfNeeded() throws {
        try fileSystem.createDirectoryIfNeeded(at: directoryURL)
        if let resourcesDirectoryURL = Bundle.module.resourceURL?.appending(path: "Resources") {
            try resourcesCopier.copyResources(from: resourcesDirectoryURL, to: directoryURL)
        }
    }

    public func removeResources() throws {
        if fileSystem.itemExists(at: directoryURL) {
            try fileSystem.removeItem(at: directoryURL)
        }
    }
}
