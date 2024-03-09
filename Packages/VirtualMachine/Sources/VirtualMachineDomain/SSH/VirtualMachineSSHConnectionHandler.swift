import SSHDomain

public protocol VirtualMachineSSHConnectionHandler {
    func didConnect(to virtualMachine: VirtualMachine, through connection: SSHConnection) async throws
}
