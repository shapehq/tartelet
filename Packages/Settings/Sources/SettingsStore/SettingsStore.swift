import Combine
import GitHubService
import Settings
import SwiftUI

public final class SettingsStore: ObservableObject {
    private enum AppStorageKey {
        static let applicationUIMode = "applicationUIMode"
        static let tartHomeFolderURL = "tartHomeFolderURL"
        static let virtualMachine = "virtualMachine"
        static let numberOfVirtualMachines = "numberOfVirtualMachines"
        static let startVirtualMachinesOnLaunch = "startVirtualMachinesOnLaunch"
        static let gitHubPrivateKeyName = "gitHubPrivateKeyName"
        static let gitHubRunnerLabels = "gitHubRunnerLabels"
        static let gitHubRunnerGroup = "gitHubRunnerGroup"
        static let githubRunnerScope = "githubRunnerScope"
        static let githubServiceVersion = "githubServiceVersion"
    }

    @AppStorage(AppStorageKey.applicationUIMode)
    public var applicationUIMode: ApplicationUIMode = .dockAndMenuBar
    @AppStorage(AppStorageKey.tartHomeFolderURL)
    public var tartHomeFolderURL: URL?
    @AppStorage(AppStorageKey.virtualMachine)
    public var virtualMachine: VirtualMachine = .unknown
    @AppStorage(AppStorageKey.numberOfVirtualMachines)
    public var numberOfVirtualMachines = 1
    @AppStorage(AppStorageKey.startVirtualMachinesOnLaunch)
    public var startVirtualMachinesOnLaunch = false
    @AppStorage(AppStorageKey.gitHubPrivateKeyName)
    public var gitHubPrivateKeyName: String?
    @AppStorage(AppStorageKey.gitHubRunnerLabels)
    public var gitHubRunnerLabels = "tartelet"
    @AppStorage(AppStorageKey.gitHubRunnerGroup)
    public var gitHubRunnerGroup = ""
    @AppStorage(AppStorageKey.githubRunnerScope)
    public var githubRunnerScope: GitHubRunnerScope = .organization
    @AppStorage(AppStorageKey.githubServiceVersion)
    public var githubServiceVersion: GitHubServiceVersion.Kind = .dotCom

    public init() {}

    public var onChange: AnyPublisher<SettingsStore, Never> {
        return objectWillChange.map { [weak self] in
            if let self = self {
                return self
            } else {
                fatalError("Unable to map value because self is nil")
            }
        }.eraseToAnyPublisher()
    }
}
