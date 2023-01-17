import Combine
import Foundation
import Tart
import VirtualMachine

public final class TartVirtualMachine: VirtualMachine {
    private let tart: Tart
    private let sourceVMName: String
    private let resourcesDirectoryURL: URL
    private let vmName: String
    private var runTask: Task<(), Error>?
    private var isRunning = false

    public init(tart: Tart, sourceVMName: String, resourcesDirectoryURL: URL) {
        self.tart = tart
        self.sourceVMName = sourceVMName
        self.vmName = sourceVMName + "-" + UUID().uuidString
        self.resourcesDirectoryURL = resourcesDirectoryURL
    }

    public func start() async throws {
        return try await withTaskCancellationHandler {
            guard !isRunning else {
                return
            }
            try await tart.clone(sourceName: sourceVMName, newName: vmName)
            let resourcesDirectory = MountedDirectory(name: "Resources", directoryURL: resourcesDirectoryURL)
            try await tart.run(name: vmName, mounting: [resourcesDirectory])
            try await self.stop()
        } onCancel: {
            Task {
                try await self.stop()
            }
        }
    }

    public func stop() async throws {
        isRunning = false
        try await self.tart.delete(name: self.vmName)
    }
}
