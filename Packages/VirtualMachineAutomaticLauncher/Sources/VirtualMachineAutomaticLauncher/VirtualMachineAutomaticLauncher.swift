import LogConsumer
import SettingsStore
import VirtualMachineFleet

public struct VirtualMachineAutomaticLauncher {
    private let logger: LogConsumer
    private let settingsStore: SettingsStore
    private let fleet: VirtualMachineFleet

    public init(logger: LogConsumer, settingsStore: SettingsStore, fleet: VirtualMachineFleet) {
        self.logger = logger
        self.settingsStore = settingsStore
        self.fleet = fleet
    }

    public func startVirtualMachinesIfNeeded() {
        guard settingsStore.startVirtualMachinesOnLaunch else {
            return
        }
        do {
            try fleet.start(numberOfMachines: settingsStore.numberOfVirtualMachines)
        } catch {
            logger.error("Failed starting virtual machines on launch: %@", error.localizedDescription)
        }
    }
}
