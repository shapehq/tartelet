import Foundation
import LoggingDomain
import SSHDomain

private enum VirtualMachineSSHClientError: LocalizedError, CustomDebugStringConvertible {
    case missingSSHUsername
    case missingSSHPassword
    case failedConnectingToVirtualMachineAfterRetries

    var errorDescription: String? {
        debugDescription
    }

    var debugDescription: String {
        switch self {
        case .missingSSHUsername:
            "The SSH username is not set in Tartelet's settings."
        case .missingSSHPassword:
            "The SSH password is not set in Tartelet's settings."
        case .failedConnectingToVirtualMachineAfterRetries:
            "Failed establishing connection to virtual machine after retrying a number of times."
        }
    }
}

public struct VirtualMachineSSHClient<SSHClientType: SSHClient> {
    private let logger: Logger
    private let client: SSHClientType
    private let ipAddressReader: VirtualMachineIPAddressReader
    private let credentialsStore: VirtualMachineSSHCredentialsStore
    private let connectionHandler: VirtualMachineSSHConnectionHandler

    public init(
        logger: Logger,
        client: SSHClientType,
        ipAddressReader: VirtualMachineIPAddressReader,
        credentialsStore: VirtualMachineSSHCredentialsStore,
        connectionHandler: VirtualMachineSSHConnectionHandler
    ) {
        self.logger = logger
        self.client = client
        self.ipAddressReader = ipAddressReader
        self.credentialsStore = credentialsStore
        self.connectionHandler = connectionHandler
    }

    func connect(to virtualMachine: VirtualMachine) async throws {
        let ipAddress = try await getIPAddress(of: virtualMachine)
        let connection = try await connectToVirtualMachine(
            named: virtualMachine.name,
            on: ipAddress,
            remainingAttempts: 3
        )
        try await connectionHandler.didConnect(to: virtualMachine, through: connection)
        try? await connection.close()
    }
}

private extension VirtualMachineSSHClient {
    private func getIPAddress(of virtualMachine: VirtualMachine) async throws -> String {
        do {
            return try await ipAddressReader.readIPAddress(of: virtualMachine)
        } catch {
            logger.error(
                "Failed obtaining IP address of virtual machine named \(virtualMachine.name): "
                + error.localizedDescription
            )
            throw error
        }
    }

    private func connectToVirtualMachine(
        named virtualMachineName: String,
        on host: String,
        remainingAttempts: Int
    ) async throws -> SSHClientType.SSHConnectionType {
        do {
            try Task.checkCancellation()
            return try await connectToVirtualMachine(named: virtualMachineName, on: host)
        } catch {
            guard remainingAttempts > 1 else {
                throw VirtualMachineSSHClientError.failedConnectingToVirtualMachineAfterRetries
            }
            try Task.checkCancellation()
            try await Task.sleep(for: .seconds(2))
            return try await connectToVirtualMachine(
                named: virtualMachineName,
                on: host,
                remainingAttempts: remainingAttempts - 1
            )
        }
    }

    private func connectToVirtualMachine(
        named virtualMachineName: String,
        on host: String
    ) async throws -> SSHClientType.SSHConnectionType {
        guard let username = credentialsStore.username else {
            logger.error(
                "Failed connecting to to \(virtualMachineName) on \(host)."
                + " The SSH username is not set in Tartelet's settings."
            )
            throw VirtualMachineSSHClientError.missingSSHUsername
        }
        guard let password = credentialsStore.password else {
            logger.error(
                "Failed connecting to to \(virtualMachineName) on \(host)."
                + " The SSH password is not set in Tartelet's settings."
            )
            throw VirtualMachineSSHClientError.missingSSHPassword
        }
        do {
            return try await client.connect(host: host, username: username, password: password)
        } catch {
            logger.error(
                "Failed connecting to \(virtualMachineName) on \(host): "
                + error.localizedDescription
            )
            throw error
        }
    }
}
