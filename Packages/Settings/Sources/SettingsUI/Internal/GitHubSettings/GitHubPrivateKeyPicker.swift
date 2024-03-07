import GitHubDomain
import SwiftUI

struct GitHubPrivateKeyPicker: View {
    @Binding private var filename: String
    private let scope: GitHubRunnerScope
    private let isEnabled: Bool
    private let onSelectFile: (URL) -> Void
    private var scopesText: String {
        switch scope {
        case .organization:
            L10n.Settings.Github.PrivateKey.Scopes.organization
        case .repo:
            L10n.Settings.Github.PrivateKey.Scopes.repository
        }
    }

    init(filename: Binding<String>, scope: GitHubRunnerScope, isEnabled: Bool, onSelectFile: @escaping (URL) -> Void) {
        self._filename = filename
        self.scope = scope
        self.isEnabled = isEnabled
        self.onSelectFile = onSelectFile
    }

    var body: some View {
        VStack(spacing: 16) {
            LabeledContent {
                VStack {
                    HStack {
                        TextField(
                            L10n.Settings.Github.privateKey,
                            text: $filename,
                            prompt: Text(L10n.Settings.Github.PrivateKey.placeholder)
                        )
                        .labelsHidden()
                        .disabled(true)
                        Button {
                            if let fileURL = presentOpenPanel() {
                                onSelectFile(fileURL)
                            }
                        } label: {
                            Text(L10n.Settings.Github.PrivateKey.selectFile)
                        }.disabled(!isEnabled)
                    }
                }
            } label: {
                Text(L10n.Settings.Github.privateKey)
            }
            Text(scopesText)
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
    }
}

private extension GitHubPrivateKeyPicker {
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
