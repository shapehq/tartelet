import Combine
import Foundation
import Tart
import TartDirectoryHelpers
import VirtualMachine

public final class TartVirtualMachine: VirtualMachine {
    public var name: String {
        vmName
    }

    private let tart: Tart
    private let vmName: String
    private let resourcesDirectoryURL: URL

    public init(tart: Tart, vmName: String, resourcesDirectoryURL: URL) {
        self.tart = tart
        self.vmName = vmName
        self.resourcesDirectoryURL = resourcesDirectoryURL
    }

    public func start() async throws {
        try await tart.run(name: vmName, mounting: [.resources(at: resourcesDirectoryURL)])
    }

    public func stop() async throws {}
}
