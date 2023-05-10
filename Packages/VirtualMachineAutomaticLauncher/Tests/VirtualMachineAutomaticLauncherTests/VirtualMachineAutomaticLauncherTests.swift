import SettingsStore
import VirtualMachineAutomaticLauncher
import XCTest

final class VirtualMachineAutomaticLauncherTests: XCTestCase {
    func testStartsVirtualMachinesWhenSettingIsEnabled() {
        let logger = LogConsumerMock()
        let settingsStore = SettingsStore()
        settingsStore.startVirtualMachinesOnLaunch = true
        let fleet = VirtualMachineFleetMock()
        let automaticLauncher = VirtualMachineAutomaticLauncher(
            logger: logger,
            settingsStore: settingsStore,
            fleet: fleet
        )
        automaticLauncher.startVirtualMachinesIfNeeded()
        XCTAssertTrue(fleet.didStartVirtualMachines)
    }

    func testDoesNotStartVirtualMachinesWhenSettingIsDisabled() {
        let logger = LogConsumerMock()
        let settingsStore = SettingsStore()
        settingsStore.startVirtualMachinesOnLaunch = false
        let fleet = VirtualMachineFleetMock()
        let automaticLauncher = VirtualMachineAutomaticLauncher(
            logger: logger,
            settingsStore: settingsStore,
            fleet: fleet
        )
        automaticLauncher.startVirtualMachinesIfNeeded()
        XCTAssertFalse(fleet.didStartVirtualMachines)
    }

    func testItLogsErrorWhenFailingToStartVirtualMachines() {
        let logger = LogConsumerMock()
        let settingsStore = SettingsStore()
        settingsStore.startVirtualMachinesOnLaunch = true
        let fleet = VirtualMachineFleetMock(shouldFailStarting: true)
        let automaticLauncher = VirtualMachineAutomaticLauncher(
            logger: logger,
            settingsStore: settingsStore,
            fleet: fleet
        )
        automaticLauncher.startVirtualMachinesIfNeeded()
        XCTAssertTrue(logger.didLogError)
    }
}
