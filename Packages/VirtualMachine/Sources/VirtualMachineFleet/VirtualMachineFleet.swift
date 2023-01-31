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

    public func start() throws {
        guard !isStarted else {
            return
        }
        isStarted = true
        let preferredName = try virtualMachineFactory.preferredVirtualMachineName
        for index in 0 ..< numberOfMachines {
            startMachine(named: preferredName + "-\(index + 1)")
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
    private func startMachine(named name: String) {
        Task {
            do {
                let virtualMachine = try await virtualMachineFactory.makeVirtualMachine(named: name)
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
            startMachine(named: virtualMachine.name)
        }
    }
}
