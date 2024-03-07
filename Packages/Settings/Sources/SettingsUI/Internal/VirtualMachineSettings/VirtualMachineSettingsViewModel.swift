import Combine
import SettingsDomain
import SwiftUI
import VirtualMachineDomain

final class VirtualMachineSettingsViewModel<SettingsStoreType: SettingsStore>: ObservableObject {
    let settingsStore: SettingsStoreType

    @Published private(set) var isRefreshingVirtualMachines = false
    @Published private(set) var isSettingsEnabled = false
    @Published private(set) var virtualMachineNames: [String] = []

    private let virtualMachinesSourceNameRepository: VirtualMachineSourceNameRepository
    private var cancellables: Set<AnyCancellable> = []

    init(
        settingsStore: SettingsStoreType,
        virtualMachinesSourceNameRepository: VirtualMachineSourceNameRepository,
        isSettingsEnabled: AnyPublisher<Bool, Never>
    ) {
        self.settingsStore = settingsStore
        self.virtualMachinesSourceNameRepository = virtualMachinesSourceNameRepository
        isSettingsEnabled.assign(to: \.isSettingsEnabled, on: self).store(in: &cancellables)
    }

    @MainActor
    func refreshVirtualMachines() async {
        isRefreshingVirtualMachines = true
        defer {
            isRefreshingVirtualMachines = false
        }
        do {
            virtualMachineNames = try await self.virtualMachinesSourceNameRepository.sourceNames()
            if case let .virtualMachine(name) = settingsStore.virtualMachine, !virtualMachineNames.contains(name) {
                settingsStore.virtualMachine = .unknown
            }
        } catch {
            #if DEBUG
            print(error)
            #endif
        }
    }
}
