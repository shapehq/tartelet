import Combine
import Foundation
import LogHelpers
import OSLog
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
    private let logger = Logger(category: "EphemeralTartVirtualMachine")

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
        let sourceVMName = sourceVMName
        let destinationVMName = destinationVMName
        logger.info("Clone Tart image named \(sourceVMName, privacy: .public) to \(destinationVMName, privacy: .public)...")
        try await tart.clone(sourceName: sourceVMName, newName: destinationVMName)
        logger.info("Run Tart image named \(destinationVMName, privacy: .public)...")
        try await tart.run(name: destinationVMName, mounting: [.resources(at: resourcesDirectoryURL)])
        logger.info("Delete Tart image named \(destinationVMName, privacy: .public)...")
        try await tart.delete(name: destinationVMName)
        onCleanup()
    }

    public func stop() async throws {
        try await tart.delete(name: destinationVMName)
        onCleanup()
    }
}
