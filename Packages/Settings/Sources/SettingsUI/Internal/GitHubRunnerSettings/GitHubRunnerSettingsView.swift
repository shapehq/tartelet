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
                    L10n.Settings.GithubRunner.name,
                    text: $settingsStore.gitHubRunnerName,
                    prompt: Text(githubRunnerNamePrompt)
                )
                .disabled(!isSettingsEnabled)

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

    private var githubRunnerNamePrompt: String {
        switch settingsStore.virtualMachine {
            case .unknown:
                return L10n.Settings.GithubRunner.Name.prompt
            case .virtualMachine(let name):
                return name
        }
    }
}
