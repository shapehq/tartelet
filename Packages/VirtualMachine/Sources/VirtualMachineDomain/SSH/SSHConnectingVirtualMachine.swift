import SSHDomain

public final class SSHConnectingVirtualMachine<SSHClientType: SSHClient>: VirtualMachine {
    public var name: String {
        virtualMachine.name
    }

    private let virtualMachine: VirtualMachine
    private let sshClient: VirtualMachineSSHClient<SSHClientType>

    public init(
        virtualMachine: VirtualMachine,
        sshClient: VirtualMachineSSHClient<SSHClientType>
    ) {
        self.virtualMachine = virtualMachine
        self.sshClient = sshClient
    }

    public func start() async throws {
        let connectTask = Task {
            let connection = try await self.sshClient.connect(to: self.virtualMachine)
            try await connection.close()
        }
        try await self.virtualMachine.start()
        connectTask.cancel()
    }

    public func clone(named newName: String) async throws -> VirtualMachine {
        let virtualMachine = try await virtualMachine.clone(named: newName)
        return SSHConnectingVirtualMachine(
            virtualMachine: virtualMachine,
            sshClient: sshClient
        )
    }

    public func delete() async throws {
        try await virtualMachine.delete()
    }

    public func getIPAddress() async throws -> String {
        try await virtualMachine.getIPAddress()
    }
}
