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
            LabeledContent {
                VStack {
                    HStack {
                        if let privateKeyName = viewModel.privateKeyName {
                            Text(privateKeyName)
                                .lineLimit(1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            Text(L10n.Settings.Github.PrivateKey.placeholder)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        Button {
                            if let fileURL = presentOpenPanel() {
                                Task {
                                    await viewModel.storePrivateKey(at: fileURL)
                                }
                            }
                        } label: {
                            Text(L10n.Settings.Github.PrivateKey.selectFile)
                        }.disabled(!viewModel.isSettingsEnabled)
                    }
                    Text(L10n.Settings.Github.PrivateKey.scopes)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.secondary)
                        .background {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.separator, lineWidth: 1)
                        }
                }
            } label: {
                Text(L10n.Settings.Github.privateKey)
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

private extension GitHubSettingsView {
    func presentOpenPanel() -> URL? {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.x509Certificate]
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        let response = openPanel.runModal()
        return response == .OK ? openPanel.url : nil
    }
}
