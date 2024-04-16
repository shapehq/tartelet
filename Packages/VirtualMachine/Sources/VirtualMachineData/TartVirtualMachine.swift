import Foundation
import VirtualMachineDomain

public final class TartVirtualMachine: VirtualMachine {
    public var name: String {
        vmName
    }
    public var canStart: Bool {
        true
    }

    private let tart: Tart
    private let vmName: String

    public init(tart: Tart, vmName: String) {
        self.tart = tart
        self.vmName = vmName
    }

    public func start() async throws {
        try await tart.run(name: vmName)
    }

    public func clone(named newName: String) async throws -> VirtualMachine {
        try await tart.clone(sourceName: name, newName: newName)
        return TartVirtualMachine(tart: tart, vmName: newName)
    }

    public func delete() async throws {
        try await tart.delete(name: name)
    }

    public func getIPAddress() async throws -> String {
        try await tart.getIPAddress(ofVirtualMachineNamed: name)
    }
}
