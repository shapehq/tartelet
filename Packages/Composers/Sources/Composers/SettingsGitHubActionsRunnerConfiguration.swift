import GitHubDomain
import SettingsDomain
import VirtualMachineDomain

public struct SettingsGitHubActionsRunnerConfiguration<
    SettingsStoreType: SettingsStore
>: GitHubActionsRunnerConfiguration {
    public let settingsStore: SettingsStoreType

    public var runnerDisableDefaultLabels: Bool {
        settingsStore.gitHubRunnerDisableDefaultLabels
    }

    public var runnerDisableUpdates: Bool {
        settingsStore.gitHubRunnerDisableUpdates
    }

    public var runnerScope: GitHubRunnerScope {
        settingsStore.githubRunnerScope
    }

    public var runnerLabels: String {
        settingsStore.gitHubRunnerLabels
    }

    public var runnerGroup: String {
        settingsStore.gitHubRunnerGroup
    }

    public var runnerName: String {
        settingsStore.gitHubRunnerName
    }
}
