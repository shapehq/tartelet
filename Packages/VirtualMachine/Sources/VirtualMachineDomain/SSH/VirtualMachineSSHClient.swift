import SSHDomain

public struct VirtualMachineSSHClient<SSHClientType: SSHClient> {
    private let client: SSHClientType
    private let ipAddressReader: VirtualMachineIPAddressReader
    private let credentials: VirtualMachineSSHCredentials
    private let connectionHandler: VirtualMachineSSHConnectionHandler

    public init(
        client: SSHClientType,
        ipAddressReader: VirtualMachineIPAddressReader,
        credentials: VirtualMachineSSHCredentials,
        connectionHandler: VirtualMachineSSHConnectionHandler
    ) {
        self.client = client
        self.ipAddressReader = ipAddressReader
        self.credentials = credentials
        self.connectionHandler = connectionHandler
    }

    func connect(to virtualMachine: VirtualMachine) async throws -> SSHClientType.SSHConnectionType {
        let ipAddress = try await ipAddressReader.readIPAddress(of: virtualMachine)
        let connection = try await client.connect(
            host: ipAddress,
            username: credentials.username,
            password: credentials.password
        )
        try await connectionHandler.didConnect(to: virtualMachine, through: connection)
        return connection
    }
}
