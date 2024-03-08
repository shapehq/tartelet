import LoggingData
import SettingsData
import ShellData
import VirtualMachineData
import VirtualMachineDomain

enum Composers {
    static let settingsStore = AppStorageSettingsStore()

    static let fleet = VirtualMachineFleet(
        logger: OSLogger(subsystem: "VirtualMachineFleet"),
        baseVirtualMachine: SettingsVirtualMachine(
            tart: Tart(
                homeProvider: SettingsTartHomeProvider(
                    settingsStore: settingsStore
                ),
                shell: ProcessShell()
            ),
            settingsStore: settingsStore
        )
    )

    static let editor = VirtualMachineEditor(
        logger: OSLogger(subsystem: "VirtualMachineEditor"),
        virtualMachine: SettingsVirtualMachine(
            tart: Tart(
                homeProvider: SettingsTartHomeProvider(
                    settingsStore: settingsStore
                ),
                shell: ProcessShell()
            ),
            settingsStore: settingsStore
        )
    )
}
