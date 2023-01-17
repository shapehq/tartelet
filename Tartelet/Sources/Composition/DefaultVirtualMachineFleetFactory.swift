import SettingsStore
import VirtualMachineFactory
import VirtualMachineFleet
import VirtualMachineFleetFactory

struct DefaultVirtualMachineFleetFactory: VirtualMachineFleetFactory {
    let settingsStore: SettingsStore
    let virtualMachineFactory: VirtualMachineFactory

    func makeFleet() throws -> VirtualMachineFleet {
        VirtualMachineFleet(
            virtualMachineFactory: virtualMachineFactory,
            numberOfMachines: settingsStore.numberOfVirtualMachines
        )
    }
}
