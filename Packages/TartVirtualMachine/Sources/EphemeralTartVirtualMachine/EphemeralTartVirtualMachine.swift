import Combine
import Foundation
import Tart
import TartDirectoryHelpers
import VirtualMachine
import VirtualMachineFactory

public final class EphemeralTartVirtualMachine: VirtualMachine {
    private let tart: Tart
    private let sourceVMName: String
    private let vmName: String
    private let resourcesDirectoryURL: URL
    private var runTask: Task<(), Error>?

    public init(tart: Tart, sourceVMName: String, resourcesDirectoryURL: URL) {
        self.tart = tart
        self.sourceVMName = sourceVMName
        self.vmName = sourceVMName + "-" + UUID().uuidString
        self.resourcesDirectoryURL = resourcesDirectoryURL
    }

    public func start() async throws {
        try await tart.clone(sourceName: sourceVMName, newName: vmName)
        try await tart.run(name: vmName, mounting: [.resources(at: resourcesDirectoryURL)])
        try await tart.delete(name: vmName)
    }

    public func stop() async throws {
        try await tart.delete(name: vmName)
    }
}
