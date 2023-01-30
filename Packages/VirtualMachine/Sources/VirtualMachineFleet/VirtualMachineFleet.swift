import VirtualMachine
import VirtualMachineFactory

public final class VirtualMachineFleet {
    private let virtualMachineFactory: VirtualMachineFactory
    private var activeMachines: [FleetParticipatingVirtualMachine] = []
    private var numberOfMachines: Int
    private var isStarted = false

    public init(virtualMachineFactory: VirtualMachineFactory, numberOfMachines: Int) {
        self.virtualMachineFactory = virtualMachineFactory
        self.numberOfMachines = numberOfMachines
    }

    public func start() {
        guard !isStarted else {
            return
        }
        isStarted = true
        for _ in 0 ..< numberOfMachines {
            startMachine()
        }
    }

    public func stop() {
        guard isStarted else {
            return
        }
        isStarted = false
        for machine in activeMachines {
            machine.stop()
        }
    }
}

private extension VirtualMachineFleet {
    func startMachine() {
        Task {
            do {
                let virtualMachine = try await virtualMachineFactory.makeVirtualMachine()
                let fleetMachine = FleetParticipatingVirtualMachine(virtualMachine: virtualMachine)
                activeMachines.append(fleetMachine)
                fleetMachine.delegate = self
                fleetMachine.start()
            } catch {
                #if DEBUG
                print(error)
                #endif
            }
        }
    }
}

extension VirtualMachineFleet: FleetParticipatingVirtualMachineDelegate {
    func virtualMachineDidStop(_ virtualMachine: FleetParticipatingVirtualMachine) {
        activeMachines.removeAll { $0 === virtualMachine }
        if isStarted && activeMachines.count < numberOfMachines {
            startMachine()
        }
    }
}
