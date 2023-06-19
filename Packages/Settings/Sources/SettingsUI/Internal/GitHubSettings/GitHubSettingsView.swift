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
            TextField(L10n.Settings.Github.organizationName, text: $viewModel.organizationName)
                .disabled(!viewModel.isSettingsEnabled)
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
        }
        .padding()
        .task {
            await viewModel.loadCredentials()
        }
    }
}
