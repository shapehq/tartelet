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
            TextField(L10n.Settings.GithubRunner.labels, text: $viewModel.labels)
                .disabled(!viewModel.isSettingsEnabled)
            Text(L10n.Settings.GithubRunner.Labels.footer)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .foregroundColor(.secondary)

            TextField(L10n.Settings.GithubRunner.group, text: $viewModel.group)
                .disabled(!viewModel.isSettingsEnabled)
            Text(L10n.Settings.GithubRunner.Group.footer)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}
