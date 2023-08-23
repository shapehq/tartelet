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
                Picker(L10n.Settings.Github.runnerScope, selection: $viewModel.runnerScope) {
                    ForEach(RunnerScope.allCases, id: \.self) { scope in
                        Text(scope.rawValue.capitalized)
                    }
                }
                .pickerStyle(.segmented)

                switch viewModel.runnerScope {
                case .organization:
                    TextField(L10n.Settings.Github.organizationName, text: $viewModel.organizationName)
                        .disabled(!viewModel.isSettingsEnabled)
                case .repo:
                    TextField(L10n.Settings.Github.ownerName, text: $viewModel.ownerName)
                        .disabled(!viewModel.isSettingsEnabled)
                    TextField(L10n.Settings.Github.repositoryName, text: $viewModel.repositoryName)
                        .disabled(!viewModel.isSettingsEnabled)
                }
            }
            Section {
                TextField(L10n.Settings.Github.appId, text: $viewModel.appId)
                    .disabled(!viewModel.isSettingsEnabled)
                GitHubPrivateKeyPicker(filename: $viewModel.privateKeyName, isEnabled: viewModel.isSettingsEnabled) { fileURL in
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
