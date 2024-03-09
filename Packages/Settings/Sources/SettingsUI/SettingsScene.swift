import GitHubDomain
import LoggingDomain
import Observation
import SettingsDomain
import SwiftUI
import VirtualMachineDomain

public struct SettingsScene<SettingsStoreType: SettingsStore & Observable>: Scene {
    private let settingsStore: SettingsStoreType
    private let gitHubCredentialsStore: GitHubCredentialsStore
    private let virtualMachineCredentialsStore: VirtualMachineSSHCredentialsStore
    private let virtualMachinesSourceNameRepository: VirtualMachineSourceNameRepository
    private let logExporter: LogExporter
    private let fleet: VirtualMachineFleet
    private let editor: VirtualMachineEditor
    private var isSettingsEnabled: Bool {
        !fleet.isStarted && !editor.isStarted
    }

    public init(
        settingsStore: SettingsStoreType,
        gitHubCredentialsStore: GitHubCredentialsStore,
        virtualMachineCredentialsStore: VirtualMachineSSHCredentialsStore,
        virtualMachinesSourceNameRepository: VirtualMachineSourceNameRepository,
        logExporter: LogExporter,
        fleet: VirtualMachineFleet,
        editor: VirtualMachineEditor
    ) {
        self.settingsStore = settingsStore
        self.gitHubCredentialsStore = gitHubCredentialsStore
        self.virtualMachineCredentialsStore = virtualMachineCredentialsStore
        self.virtualMachinesSourceNameRepository = virtualMachinesSourceNameRepository
        self.logExporter = logExporter
        self.fleet = fleet
        self.editor = editor
    }

    public var body: some Scene {
        Settings {
            SettingsView(
                settingsStore: settingsStore,
                gitHubCredentialsStore: gitHubCredentialsStore,
                virtualMachineCredentialsStore: virtualMachineCredentialsStore,
                virtualMachinesSourceNameRepository: virtualMachinesSourceNameRepository,
                logExporter: logExporter,
                isSettingsEnabled: isSettingsEnabled
            )
        }
    }
}
