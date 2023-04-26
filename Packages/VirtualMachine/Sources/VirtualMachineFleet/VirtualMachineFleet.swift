import Combine
import VirtualMachine
import VirtualMachineFactory

public final class VirtualMachineFleet {
    public let isStarted: AnyPublisher<Bool, Never>

    private let virtualMachineFactory: VirtualMachineFactory
    private var activeTasks: [Task<(), Error>] = []
    private let _isStarted = CurrentValueSubject<Bool, Never>(false)

    public init(virtualMachineFactory: VirtualMachineFactory) {
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

private extension VirtualMachineFleet {
    private func startSequentiallyRunningVirtualMachines(named name: String) {
        let task = Task {
            while !Task.isCancelled {
                try await runVirtualMachine(named: name)
            }
        }
        activeTasks.append(task)
    }

    private func runVirtualMachine(named name: String) async throws {
        let virtualMachine = try await virtualMachineFactory.makeVirtualMachine(named: name)
        try await withTaskCancellationHandler {
            try await virtualMachine.start()
        } onCancel: {
            Task.detached(priority: .high) {
                try await virtualMachine.stop()
            }
        }
    }
}
