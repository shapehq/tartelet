import SwiftUI

struct TartHomeFolderPicker: View {
    @Binding var folderURL: URL?
    let isEnabled: Bool

    private var folderPath: String {
        if let folderURL {
            folderURL.path(percentEncoded: false)
        } else {
            L10n.Settings.VirtualMachine.TartHome.placeholder
        }
    }

    var body: some View {
        LabeledContent {
            HStack {
                Text(folderPath)
                    .foregroundStyle(.secondary)
                Button {
                    if let selectedFolderURL = presentOpenPanel() {
                        Task {
                            folderURL = selectedFolderURL
                        }
                    }
                } label: {
                    Text(L10n.Settings.VirtualMachine.TartHome.selectFolder)
                        .fixedSize()
                }
                .disabled(!isEnabled)
                Button {
                    folderURL = nil
                } label: {
                    Text(L10n.Settings.VirtualMachine.TartHome.resetToDefault)
                        .fixedSize()
                }
                .disabled(!isEnabled)
            }
        } label: {
            Text(L10n.Settings.VirtualMachine.TartHome.folder)
        }
    }
}

private extension TartHomeFolderPicker {
    private func presentOpenPanel() -> URL? {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.folder]
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        let response = openPanel.runModal()
        return response == .OK ? openPanel.url : nil
    }
}
