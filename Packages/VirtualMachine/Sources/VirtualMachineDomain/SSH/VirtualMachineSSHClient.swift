import LoggingDomain
import SSHDomain

public struct VirtualMachineSSHClient<SSHClientType: SSHClient> {
    private let logger: Logger
    private let client: SSHClientType
    private let ipAddressReader: VirtualMachineIPAddressReader
    private let credentials: VirtualMachineSSHCredentials
    private let connectionHandler: VirtualMachineSSHConnectionHandler

    public init(
        logger: Logger,
        client: SSHClientType,
        ipAddressReader: VirtualMachineIPAddressReader,
        credentials: VirtualMachineSSHCredentials,
        connectionHandler: VirtualMachineSSHConnectionHandler
    ) {
        self.logger = logger
        self.client = client
        self.ipAddressReader = ipAddressReader
        self.credentials = credentials
        self.connectionHandler = connectionHandler
    }

    func connect(to virtualMachine: VirtualMachine) async throws -> SSHClientType.SSHConnectionType {
        let ipAddress = try await getIPAddress(of: virtualMachine)
        let connection = try await connectToVirtualMachine(named: virtualMachine.name, on: ipAddress)
        try await connectionHandler.didConnect(to: virtualMachine, through: connection)
        return connection
    }
}

private extension VirtualMachineSSHClient {
    private func getIPAddress(of virtualMachine: VirtualMachine) async throws -> String {
        do {
            return try await ipAddressReader.readIPAddress(of: virtualMachine)
        } catch {
            logger.error("Failed obtaining IP address of virtual machine named \(virtualMachine.name): \(error.localizedDescription)")
            throw error
        }
    }

    private func connectToVirtualMachine(
        named virtualMachineName: String,
        on host: String
    ) async throws -> SSHClientType.SSHConnectionType {
        do {
            return try await client.connect(
                host: host,
                username: credentials.username,
                password: credentials.password
            )
        } catch {
            logger.error("Failed connecting to \(virtualMachineName) on \(host): \(error.localizedDescription)")
            throw error
        }
    }
}
