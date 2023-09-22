import Combine
import LogHelpers
import OSLog
import VirtualMachine
import VirtualMachineFactory
import VirtualMachineFleet

public final class VirtualMachineFleetLive: VirtualMachineFleet {
    public let isStarted: AnyPublisher<Bool, Never>
    public let isStopping: AnyPublisher<Bool, Never>

    private let logger = Logger(category: "VirtualMachineFleetLive")
    private let virtualMachineFactory: VirtualMachineFactory
    private var activeTasks: [String: Task<(), Never>] = [:]
    private let _isStarted = CurrentValueSubject<Bool, Never>(false)
    private let _isStopping = CurrentValueSubject<Bool, Never>(false)

    public init(virtualMachineFactory: VirtualMachineFactory) {
        self.virtualMachineFactory = virtualMachineFactory
        self.isStarted = _isStarted.eraseToAnyPublisher()
        self.isStopping = _isStopping.eraseToAnyPublisher()
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

    public func stopImmediately() {
        _isStarted.value = false
        _isStopping.value = false
        for (_, task) in activeTasks {
            task.cancel()
        }
        activeTasks = [:]
    }

    public func stop() {
        _isStopping.value = true
    }
}

private extension VirtualMachineFleetLive {
    private func startSequentiallyRunningVirtualMachines(named name: String) {
        let task = Task {
            while !Task.isCancelled {
                do {
                    try await runVirtualMachine(named: name)
                    if _isStopping.value {
                        activeTasks[name]?.cancel()
                    }
                } catch {
                    // Ignore the error and try again until the task is cancelled.
                    // The error should have been logged using OSLog so we know what is going on in case we need to debug.
                    // However, the actual error is not important at this point so we ignore it and let the loop run again,
                    // thus giving us another chance to start the virtual machine.
                }
            }
            logger.info("Task running virtual machine named \(name, privacy: .public) was cancelled.")
            activeTasks.removeValue(forKey: name)
            if activeTasks.isEmpty {
                stopImmediately()
            }
        }
        activeTasks[name] = task
    }

    private func runVirtualMachine(named name: String) async throws {
        let virtualMachine: VirtualMachine
        do {
            virtualMachine = try await virtualMachineFactory.makeVirtualMachine(named: name)
        } catch {
            logger.error("Could not create virtual machine named \(name, privacy: .public): \(error.localizedDescription, privacy: .public)")
            throw error
        }
        try await withTaskCancellationHandler {
            logger.info("Start virtual machine named \(name, privacy: .public)")
            do {
                try await virtualMachine.start()
                logger.info("Did stop virtual machine named \(name, privacy: .public)")
            } catch {
                logger.info("Virtual machine named \(name, privacy: .public) stopped with message: \(error.localizedDescription, privacy: .public)")
                throw error
            }
        } onCancel: {
            Task.detached(priority: .high) {
                self.logger.info("Stop virtual machine named \(name, privacy: .public)")
                do {
                    try await virtualMachine.stop()
                } catch {
                    // swiftlint:disable:next line_length
                    self.logger.info("Could not stop virtual machine named \(name, privacy: .public): \(error.localizedDescription, privacy: .public)")
                    throw error
                }
            }
        }
    }
}
