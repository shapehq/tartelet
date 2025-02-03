import GitHubDomain
import SettingsDomain
import VirtualMachineDomain

struct SettingsGitHubActionsRunnerConfiguration<
    SettingsStoreType: SettingsStore
>: GitHubActionsRunnerConfiguration {
    let settingsStore: SettingsStoreType
    var runnerDisableUpdates: Bool {
        settingsStore.gitHubRunnerDisableUpdates
    }
    var runnerScope: GitHubRunnerScope {
        settingsStore.githubRunnerScope
    }
    var runnerLabels: String {
        settingsStore.gitHubRunnerLabels
    }
    var runnerGroup: String {
        settingsStore.gitHubRunnerGroup
    }
}
