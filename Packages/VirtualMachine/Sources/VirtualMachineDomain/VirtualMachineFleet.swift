import LoggingDomain
import Observation

@Observable
public final class VirtualMachineFleet {
    public private(set) var isStarted = false
    public private(set) var isStopping = false

    private let logger: Logger
    private let baseVirtualMachine: VirtualMachine
    private var activeTasks: [String: Task<(), Never>] = [:]

    public init(logger: Logger, baseVirtualMachine: VirtualMachine) {
        self.logger = logger
        self.baseVirtualMachine = baseVirtualMachine
    }

    public func start(numberOfMachines: Int) throws {
        guard !isStarted else {
            return
        }
        isStarted = true
        for index in 0 ..< numberOfMachines {
            let name = baseVirtualMachine.name + "-\(index + 1)"
            startSequentiallyRunningVirtualMachines(named: name)
        }
    }

    public func stopImmediately() {
        isStarted = false
        isStopping = false
        for (_, task) in activeTasks {
            task.cancel()
        }
        activeTasks = [:]
    }

    public func stop() {
        isStopping = true
    }
}

private extension VirtualMachineFleet {
    private func startSequentiallyRunningVirtualMachines(named name: String) {
        let task = Task {
            while !Task.isCancelled {
                do {
                    let virtualMachine = try await baseVirtualMachine.clone(named: name)
                    try await runVirtualMachine(virtualMachine)
                    if isStopping {
                        activeTasks[name]?.cancel()
                    }
                } catch {
                    // Ignore the error and try again until the task is cancelled. The error should
                    // have been logged so we know what is going on in case we need to debug.
                    // However, the actual error is not important at this point so we ignore it and
                    // let the loop run again, thus giving us another chance to start the virtual machine.
                }
            }
            logger.info("Task running virtual machine named \(name) was cancelled.")
            activeTasks.removeValue(forKey: name)
            if activeTasks.isEmpty {
                stopImmediately()
            }
        }
        activeTasks[name] = task
    }

    private func runVirtualMachine(_ virtualMachine: VirtualMachine) async throws {
        try await withTaskCancellationHandler {
            logger.info("Start virtual machine named \(virtualMachine.name)")
            do {
                try await virtualMachine.start()
                logger.info("Did stop virtual machine named \(virtualMachine.name)")
                do {
                    try await virtualMachine.delete()
                    logger.info("Did delete virtual machine named \(virtualMachine.name)")
                } catch {
                    logger.info("Could not delete virtual machine named \(virtualMachine.name)")
                    throw error
                }
            } catch {
                logger.info(
                    "Virtual machine named \(virtualMachine.name) stopped with message: "
                    + error.localizedDescription
                )
                throw error
            }
        } onCancel: {
            Task.detached(priority: .high) {
                self.logger.info("Stop virtual machine named \(virtualMachine.name)")
                do {
                    try await virtualMachine.delete()
                } catch {
                    self.logger.info(
                        "Could not delete virtual machine named \(virtualMachine.name): "
                        + error.localizedDescription
                    )
                    throw error
                }
            }
        }
    }
}
