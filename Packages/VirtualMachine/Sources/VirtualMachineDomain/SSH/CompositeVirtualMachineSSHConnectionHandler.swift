import SSHDomain

public struct CompositeVirtualMachineSSHConnectionHandler: VirtualMachineSSHConnectionHandler {
    private let handlers: [VirtualMachineSSHConnectionHandler]

    public init(_ handlers: [VirtualMachineSSHConnectionHandler]) {
        self.handlers = handlers
    }

    public func didConnect(to virtualMachine: VirtualMachine, through connection: SSHConnection) async throws {
        for handler in handlers {
            try await handler.didConnect(to: virtualMachine, through: connection)
        }
    }
}
