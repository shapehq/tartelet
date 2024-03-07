import Combine
import GitHubDomain
import LoggingDomain
import SettingsDomain
import SwiftUI
import VirtualMachineDomain

public struct SettingsScene<SettingsStoreType: SettingsStore>: Scene {
    private let settingsStore: SettingsStoreType
    private let gitHubCredentialsStore: GitHubCredentialsStore
    private let virtualMachinesSourceNameRepository: VirtualMachineSourceNameRepository
    private let logExporter: LogExporter
    private let isVirtualMachineSettingsEnabled: AnyPublisher<Bool, Never>

    public init(
        settingsStore: SettingsStoreType,
        gitHubCredentialsStore: GitHubCredentialsStore,
        sourceNameRepository: VirtualMachineSourceNameRepository,
        logExporter: LogExporter,
        fleet: VirtualMachineFleet,
        editor: VirtualMachineEditor
    ) {
        self.settingsStore = settingsStore
        self.gitHubCredentialsStore = gitHubCredentialsStore
        self.virtualMachinesSourceNameRepository = sourceNameRepository
        self.logExporter = logExporter
        self.isVirtualMachineSettingsEnabled = Publishers.CombineLatest(
            fleet.isStarted,
            editor.isStarted
        )
        .map { !$0 && !$1 }
        .eraseToAnyPublisher()
    }

    public var body: some Scene {
        Settings {
            SettingsView(
                settingsStore: settingsStore,
                gitHubCredentialsStore: gitHubCredentialsStore,
                virtualMachinesSourceNameRepository: virtualMachinesSourceNameRepository,
                logExporter: logExporter,
                isVirtualMachineSettingsEnabled: isVirtualMachineSettingsEnabled
            )
        }
    }
}
