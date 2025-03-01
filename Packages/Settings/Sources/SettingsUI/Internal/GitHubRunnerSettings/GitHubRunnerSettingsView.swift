import Observation
import SettingsDomain
import SwiftUI

struct GitHubRunnerSettingsView<SettingsStoreType: SettingsStore & Observable>: View {
    @Bindable var settingsStore: SettingsStoreType
    let isSettingsEnabled: Bool

    var body: some View {
        Form {
            Section {
                TextField(
                    L10n.Settings.GithubRunner.labels,
                    text: $settingsStore.gitHubRunnerLabels,
                    prompt: Text(L10n.Settings.GithubRunner.Labels.prompt)
                )
                .disabled(!isSettingsEnabled)
            } footer: {
                Text(L10n.Settings.GithubRunner.Labels.footer)
            }
            Section {
                TextField(
                    L10n.Settings.GithubRunner.group,
                    text: $settingsStore.gitHubRunnerGroup,
                    prompt: Text(L10n.Settings.GithubRunner.Group.prompt)
                )
                .disabled(!isSettingsEnabled)
            }
            Section {
                Toggle(isOn: $settingsStore.gitHubRunnerDisableUpdates) {
                    Text(L10n.Settings.GithubRunner.disableUpdates)
                    Text(L10n.Settings.GithubRunner.DisableUpdates.subtitle)
                }
                .disabled(!isSettingsEnabled)
            }
        }
        .formStyle(.grouped)
    }
}
