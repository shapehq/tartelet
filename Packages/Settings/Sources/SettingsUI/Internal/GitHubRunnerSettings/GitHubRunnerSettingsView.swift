import SettingsStore
import SwiftUI

struct GitHubRunnerSettingsView: View {
    @StateObject private var viewModel: GitHubRunnerSettingsViewModel
    @ObservedObject private var settingsStore: SettingsStore

    init(viewModel: GitHubRunnerSettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        settingsStore = viewModel.settingsStore
    }

    var body: some View {
        Form {
            Section {
                TextField(
                    L10n.Settings.GithubRunner.labels,
                    text: $viewModel.labels,
                    prompt: Text(L10n.Settings.GithubRunner.Labels.prompt)
                )
                .disabled(!viewModel.isSettingsEnabled)
            } footer: {
                Text(L10n.Settings.GithubRunner.Labels.footer)
                    .foregroundColor(.secondary)
            }
            Section {
                TextField(
                    L10n.Settings.GithubRunner.group,
                    text: $viewModel.group,
                    prompt: Text(L10n.Settings.GithubRunner.Group.prompt)
                )
                .disabled(!viewModel.isSettingsEnabled)
            }
        }
        .formStyle(.grouped)
    }
}
