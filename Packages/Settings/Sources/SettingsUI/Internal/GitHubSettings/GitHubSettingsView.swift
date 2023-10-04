import GitHubService
import SettingsStore
import SwiftUI

struct GitHubSettingsView: View {
    @StateObject private var viewModel: GitHubSettingsViewModel
    @ObservedObject private var settingsStore: SettingsStore

    init(viewModel: GitHubSettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        settingsStore = viewModel.settingsStore
    }

    var body: some View {
        Form {
            Section {
                Picker("Version", selection: $viewModel.version) {
                    ForEach(GitHubServiceVersion.Kind.allCases, id: \.self) { scope in
                        Text(scope.title)
                    }
                }

                if viewModel.version == .enterprise {
                    TextField(
                        "Self hosted URL",
                        text: $viewModel.selfHostedRaw,
                        prompt: Text("Github Service raw value")
                    )
                    .disabled(!viewModel.isSettingsEnabled)
                }

                Picker(L10n.Settings.Github.runnerScope, selection: $viewModel.runnerScope) {
                    ForEach(GitHubRunnerScope.allCases, id: \.self) { scope in
                        Text(scope.title)
                    }
                }
                .pickerStyle(.segmented)
                switch viewModel.runnerScope {
                case .organization:
                    TextField(
                        L10n.Settings.Github.organizationName,
                        text: $viewModel.organizationName,
                        prompt: Text(L10n.Settings.Github.OrganizationName.prompt)
                    )
                    .disabled(!viewModel.isSettingsEnabled)
                case .repo:
                    TextField(
                        L10n.Settings.Github.ownerName,
                        text: $viewModel.ownerName,
                        prompt: Text(L10n.Settings.Github.OwnerName.prompt)
                    )
                    .disabled(!viewModel.isSettingsEnabled)
                    TextField(
                        L10n.Settings.Github.repositoryName,
                        text: $viewModel.repositoryName,
                        prompt: Text(L10n.Settings.Github.RepositoryName.prompt)
                    )
                    .disabled(!viewModel.isSettingsEnabled)
                }
            }
            Section {
                TextField(L10n.Settings.Github.appId, text: $viewModel.appId)
                    .disabled(!viewModel.isSettingsEnabled)
                GitHubPrivateKeyPicker(
                    filename: $viewModel.privateKeyName,
                    scope: viewModel.runnerScope,
                    isEnabled: viewModel.isSettingsEnabled
                ) { fileURL in
                    Task {
                        await viewModel.storePrivateKey(at: fileURL)
                    }
                }
                Button {
                    viewModel.openCreateApp()
                } label: {
                    Text(L10n.Settings.Github.createApp)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .formStyle(.grouped)
        .task {
            await viewModel.loadCredentials()
        }
    }
}

private extension GitHubRunnerScope {
    var title: String {
        switch self {
        case .organization:
            L10n.Settings.RunnerScope.organization
        case .repo:
            L10n.Settings.RunnerScope.repository
        }
    }
}

private extension GitHubServiceVersion.Kind {
    var title: String {
        switch self {
        case .dotCom:
            return "github.com"
        case .enterprise:
            return "github self hosted"
        }
    }
}
