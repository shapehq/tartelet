import Combine
import SettingsDomain
import SwiftUI
import VirtualMachineDomain

final class VirtualMachineSettingsViewModel<SettingsStoreType: SettingsStore>: ObservableObject {
    let settingsStore: SettingsStoreType

    @Published private(set) var isRefreshingVirtualMachines = false
    @Published private(set) var isSettingsEnabled = false
    @Published private(set) var virtualMachineNames: [String] = []
    @Published var sshUsername = "" {
        didSet {
            if sshUsername != oldValue {
                credentialsStore.setUsername(sshUsername)
            }
        }
    }
    @Published var sshPassword = "" {
        didSet {
            if sshPassword != oldValue {
                credentialsStore.setPassword(sshPassword)
            }
        }
    }

    private let virtualMachinesSourceNameRepository: VirtualMachineSourceNameRepository
    private let credentialsStore: VirtualMachineSSHCredentialsStore
    private var cancellables: Set<AnyCancellable> = []

    init(
        settingsStore: SettingsStoreType,
        virtualMachinesSourceNameRepository: VirtualMachineSourceNameRepository,
        credentialsStore: VirtualMachineSSHCredentialsStore,
        isSettingsEnabled: AnyPublisher<Bool, Never>
    ) {
        self.settingsStore = settingsStore
        self.virtualMachinesSourceNameRepository = virtualMachinesSourceNameRepository
        self.credentialsStore = credentialsStore
        self.sshUsername = credentialsStore.username ?? ""
        self.sshPassword = credentialsStore.password ?? ""
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
