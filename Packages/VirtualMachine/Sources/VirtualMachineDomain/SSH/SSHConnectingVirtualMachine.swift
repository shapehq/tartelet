import Foundation
import LoggingDomain
import SSHDomain

private enum StartVirtualMachineValue {
    case virtualMachineTerminated
    case sshConnectionCompleted
}

private enum StartVirtualMachineError: LocalizedError, CustomDebugStringConvertible {
    case failedStartingVirtualMachine(Error)
    case failedEstablishingSSHConnection(Error)
    case cancelled

    var errorDescription: String? {
        debugDescription
    }

    var debugDescription: String {
        switch self {
        case .failedStartingVirtualMachine:
            "Failed starting virtual machine"
        case .failedEstablishingSSHConnection:
            "Failed establishing SSH connection"
        case .cancelled:
            "Task was cancelled"
        }
    }
}

private typealias StartVirtualMachineResult = Result<StartVirtualMachineValue, StartVirtualMachineError>

public final class SSHConnectingVirtualMachine<SSHClientType: SSHClient>: VirtualMachine {
    public var name: String {
        virtualMachine.name
    }
    public var canStart: Bool {
        virtualMachine.canStart
    }

    private let logger: Logger
    private let virtualMachine: VirtualMachine
    private let sshClient: VirtualMachineSSHClient<SSHClientType>

    public init(
        logger: Logger,
        virtualMachine: VirtualMachine,
        sshClient: VirtualMachineSSHClient<SSHClientType>
    ) {
        self.logger = logger
        self.virtualMachine = virtualMachine
        self.sshClient = sshClient
    }

    public func start() async throws {
        try await withThrowingTaskGroup(of: StartVirtualMachineResult.self) { group in
            group.addTask {
                return try await self.startVirtualMachine()
            }
            group.addTask {
                return try await self.connect(to: self.virtualMachine)
            }
            for try await result in group {
                switch result {
                case let .success(value):
                    switch value {
                    case .virtualMachineTerminated:
                        // In the happy path, the SSH connection has already been established,
                        // but we'll cancel it in the odd case that it hasn't.
                        group.cancelAll()
                    case .sshConnectionCompleted:
                        // Nothing to do. The virtual machine should keep running.
                        break
                    }
                case let .failure(error):
                    switch error {
                    case .failedStartingVirtualMachine, .failedEstablishingSSHConnection:
                        // If we fail to start the virtual machine or establish the SSH connection,
                        // then we'll cancel the other operations. This ensures the virtual machine is
                        // shut down and enables the VirtualMachineFleet to start a new virtual machine.
                        group.cancelAll()
                        throw error
                    case .cancelled:
                        // The operation was canceled, so there's nothing left for us to do.
                        break
                    }
                }
            }
        }
    }

    public func clone(named newName: String) async throws -> VirtualMachine {
        let virtualMachine = try await virtualMachine.clone(named: newName)
        return SSHConnectingVirtualMachine(
            logger: logger,
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

private extension SSHConnectingVirtualMachine {
    private func startVirtualMachine() async throws -> StartVirtualMachineResult {
        do {
            try await self.virtualMachine.start()
            return .success(.virtualMachineTerminated)
        } catch {
            if error is CancellationError {
                return .failure(.cancelled)
            } else {
                return .failure(.failedStartingVirtualMachine(error))
            }
        }
    }

    private func connect(to virtualMachine: VirtualMachine) async throws -> StartVirtualMachineResult {
        do {
            let connection = try await sshClient.connect(to: virtualMachine)
            try await connection.close()
            return .success(.sshConnectionCompleted)
        } catch {
            if error is CancellationError {
                return .failure(.cancelled)
            } else {
                logger.error(error.localizedDescription)
                logger.error(
                    "Could not connect to the virtual machine over SSH, so the virtual machine will be shut down."
                )
                return .failure(.failedEstablishingSSHConnection(error))
            }
        }
    }
}
