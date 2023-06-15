import SettingsStore
import VirtualMachineAutomaticLauncher
import XCTest

final class VirtualMachineAutomaticLauncherTests: XCTestCase {
    func testStartsVirtualMachinesWhenSettingIsEnabled() {
        let settingsStore = SettingsStore()
        settingsStore.startVirtualMachinesOnLaunch = true
        let fleet = VirtualMachineFleetMock()
        let automaticLauncher = VirtualMachineAutomaticLauncher(
            settingsStore: settingsStore,
            fleet: fleet
        )
        automaticLauncher.startVirtualMachinesIfNeeded()
        XCTAssertTrue(fleet.didStartVirtualMachines)
    }

    func testDoesNotStartVirtualMachinesWhenSettingIsDisabled() {
        let settingsStore = SettingsStore()
        settingsStore.startVirtualMachinesOnLaunch = false
        let fleet = VirtualMachineFleetMock()
        let automaticLauncher = VirtualMachineAutomaticLauncher(
            settingsStore: settingsStore,
            fleet: fleet
        )
        automaticLauncher.startVirtualMachinesIfNeeded()
        XCTAssertFalse(fleet.didStartVirtualMachines)
    }
}
