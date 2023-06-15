import Combine
import Foundation
import Tart
import TartDirectoryHelpers
import VirtualMachine
import VirtualMachineFactory

public final class EphemeralTartVirtualMachine: VirtualMachine {
    public typealias CleanupHandler = () -> Void
    public var name: String {
        destinationVMName
    }

    private let tart: Tart
    private let sourceVMName: String
    private let destinationVMName: String
    private let resourcesDirectoryURL: URL
    private let onCleanup: CleanupHandler
    private var runTask: Task<(), Error>?

    public init(
        tart: Tart,
        sourceVMName: String,
        destinationVMName: String,
        resourcesDirectoryURL: URL,
        onCleanup: @escaping CleanupHandler
    ) {
        self.tart = tart
        self.sourceVMName = sourceVMName
        self.destinationVMName = destinationVMName
        self.resourcesDirectoryURL = resourcesDirectoryURL
        self.onCleanup = onCleanup
    }

    public func start() async throws {
        defer {
            onCleanup()
        }
        try await tart.clone(sourceName: sourceVMName, newName: destinationVMName)
        try await tart.run(name: destinationVMName, mounting: [.resources(at: resourcesDirectoryURL)])
        try await tart.delete(name: destinationVMName)
        onCleanup()
    }

    public func stop() async throws {
        defer {
            onCleanup()
        }
        try await tart.delete(name: destinationVMName)
    }
}
