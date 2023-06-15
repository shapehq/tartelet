import LogHelpers
import OSLog
import SettingsStore
import VirtualMachineFleet

public struct VirtualMachineAutomaticLauncher {
    private let logger = Logger(category: "VirtualMachineAutomaticLauncher")
    private let settingsStore: SettingsStore
    private let fleet: VirtualMachineFleet

    public init(settingsStore: SettingsStore, fleet: VirtualMachineFleet) {
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
            logger.error("Failed starting virtual machines on launch: \(error.localizedDescription, privacy: .public)")
        }
    }
}
