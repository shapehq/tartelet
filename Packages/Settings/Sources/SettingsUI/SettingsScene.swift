import Combine
import SettingsStore
import SwiftUI
import VirtualMachineFleetService
import VirtualMachineSourceNameRepository

public struct SettingsScene: Scene {
    private let settingsStore: SettingsStore
    private let virtualMachinesSourceNameRepository: VirtualMachineSourceNameRepository
    private let isVirtualMachineSettingsEnabled: AnyPublisher<Bool, Never>

    public init(
        settingsStore: SettingsStore,
        virtualMachinesSourceNameRepository: VirtualMachineSourceNameRepository,
        virtualMachineFleetService: VirtualMachineFleetService
    ) {
        self.settingsStore = settingsStore
        self.virtualMachinesSourceNameRepository = virtualMachinesSourceNameRepository
        self.isVirtualMachineSettingsEnabled = virtualMachineFleetService.isStarted.map { !$0 }.eraseToAnyPublisher()
    }

    public var body: some Scene {
        Settings {
            SettingsView(
                settingsStore: settingsStore,
                virtualMachinesSourceNameRepository: virtualMachinesSourceNameRepository,
                isVirtualMachineSettingsEnabled: isVirtualMachineSettingsEnabled
            )
        }
    }
}
