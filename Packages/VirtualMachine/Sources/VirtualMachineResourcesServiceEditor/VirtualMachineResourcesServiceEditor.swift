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
    }
}
