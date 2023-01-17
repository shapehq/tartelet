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
        runTask = Task { [weak self] in
            if let self = self {
                try await self.virtualMachine.start()
                self.delegate?.virtualMachineDidStop(self)
            }
        } 
    }

    func stop() {
        runTask?.cancel()
        runTask = nil
    }
}
