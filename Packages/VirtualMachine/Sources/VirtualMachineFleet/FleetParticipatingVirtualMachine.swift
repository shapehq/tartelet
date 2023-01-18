import VirtualMachine

protocol FleetParticipatingVirtualMachineDelegate: AnyObject {
    func virtualMachineDidStop(_ virtualMachine: FleetParticipatingVirtualMachine)
}

final class FleetParticipatingVirtualMachine {
    weak var delegate: FleetParticipatingVirtualMachineDelegate?

    private let virtualMachine: VirtualMachine
    private var runTask: Task<(), Error>?

    init(virtualMachine: VirtualMachine) {
        self.virtualMachine = virtualMachine
    }

    func start() {
        runTask = Task {
            try await withTaskCancellationHandler {
                try await self.virtualMachine.start()
                self.runTask = nil
                self.delegate?.virtualMachineDidStop(self)
            } onCancel: {
                runTask = Task {
                    try await self.virtualMachine.stop()
                    self.runTask = nil
                }
            }
        }
    }

    func stop() {
        runTask?.cancel()
    }
}
