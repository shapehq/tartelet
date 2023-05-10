import Combine
import GitHubCredentialsStore
import LogExporter
import SettingsStore
import SwiftUI
import VirtualMachineEditorService
import VirtualMachineFleet
import VirtualMachineSourceNameRepository

public struct SettingsScene: Scene {
    private let settingsStore: SettingsStore
    private let gitHubCredentialsStore: GitHubCredentialsStore
    private let virtualMachinesSourceNameRepository: VirtualMachineSourceNameRepository
    private let logExporter: LogExporter
    private let isVirtualMachineSettingsEnabled: AnyPublisher<Bool, Never>

    public init(
        settingsStore: SettingsStore,
        gitHubCredentialsStore: GitHubCredentialsStore,
        sourceNameRepository: VirtualMachineSourceNameRepository,
        logExporter: LogExporter,
        fleet: VirtualMachineFleet,
        editorService: VirtualMachineEditorService
    ) {
        self.settingsStore = settingsStore
        self.gitHubCredentialsStore = gitHubCredentialsStore
        self.virtualMachinesSourceNameRepository = sourceNameRepository
        self.logExporter = logExporter
        self.isVirtualMachineSettingsEnabled = Publishers.CombineLatest(
            fleet.isStarted,
            editorService.isStarted
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
