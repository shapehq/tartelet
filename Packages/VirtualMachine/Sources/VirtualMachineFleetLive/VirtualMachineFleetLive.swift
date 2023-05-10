import Combine
import LogConsumer
import VirtualMachine
import VirtualMachineFactory
import VirtualMachineFleet

public final class VirtualMachineFleetLive: VirtualMachineFleet {
    public let isStarted: AnyPublisher<Bool, Never>

    private let logger: LogConsumer
    private let virtualMachineFactory: VirtualMachineFactory
    private var activeTasks: [Task<(), Error>] = []
    private let _isStarted = CurrentValueSubject<Bool, Never>(false)

    public init(logger: LogConsumer, virtualMachineFactory: VirtualMachineFactory) {
        self.logger = logger
        self.virtualMachineFactory = virtualMachineFactory
        self.isStarted = _isStarted.eraseToAnyPublisher()
    }

    public func start(numberOfMachines: Int) throws {
        guard !_isStarted.value else {
            return
        }
        _isStarted.value = true
        let preferredName = try virtualMachineFactory.preferredVirtualMachineName
        for index in 0 ..< numberOfMachines {
            let name = preferredName + "-\(index + 1)"
            startSequentiallyRunningVirtualMachines(named: name)
        }
    }

    public func stop() {
        guard _isStarted.value else {
            return
        }
        _isStarted.value = false
        for task in activeTasks {
            task.cancel()
        }
        activeTasks = []
    }
}

private extension VirtualMachineFleetLive {
    private func startSequentiallyRunningVirtualMachines(named name: String) {
        let task = Task {
            while !Task.isCancelled {
                try await runVirtualMachine(named: name)
            }
        }
        activeTasks.append(task)
    }

    private func runVirtualMachine(named name: String) async throws {
        let virtualMachine: VirtualMachine
        do {
            virtualMachine = try await virtualMachineFactory.makeVirtualMachine(named: name)
        } catch {
            logger.error("Could not create virtual machine named \"%@\": %@", name, error.localizedDescription)
            throw error
        }
        try await withTaskCancellationHandler {
            logger.info("Start virtual machine named \"%@\"", name)
            do {
                try await virtualMachine.start()
                logger.info("Did stop virtual machine named \"%@\"", name)
            } catch {
                logger.info("Could not start virtual machine named \"%@\": %@", name, error.localizedDescription)
                throw error
            }
        } onCancel: {
            Task.detached(priority: .high) {
                self.logger.info("Stop virtual machine named \"%@\"", name)
                do {
                    try await virtualMachine.stop()
                } catch {
                    self.logger.info("Could not stop virtual machine named \"%@\": %@", name, error.localizedDescription)
                    throw error
                }
            }
        }
    }
}
