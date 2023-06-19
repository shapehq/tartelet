import SwiftUI

struct TartHomeFolderPicker: View {
    @Binding private var folderURL: URL?
    private let isEnabled: Bool
    @State private var folderPath = ""

    init(folderURL: Binding<URL?>, isEnabled: Bool) {
        self._folderURL = folderURL
        self.isEnabled = isEnabled
        folderPath = folderURL.wrappedValue?.path() ?? ""
    }

    var body: some View {
        LabeledContent {
            VStack(alignment: .leading) {
                HStack {
                    TextField(
                        L10n.Settings.VirtualMachine.tartHomeFolder,
                        text: $folderPath,
                        prompt: Text(L10n.Settings.VirtualMachine.TartHomeFolder.placeholder)
                    )
                    .labelsHidden()
                    .disabled(true)
                    Button {
                        folderURL = nil
                    } label: {
                        Text(L10n.Settings.VirtualMachine.TartHomeFolder.resetToDefault)
                    }.disabled(!isEnabled)
                    Button {
                        if let selectedFolderURL = presentOpenPanel() {
                            Task {
                                folderURL = selectedFolderURL
                            }
                        }
                    } label: {
                        Text(L10n.Settings.VirtualMachine.TartHomeFolder.selectFolder)
                    }.disabled(!isEnabled)
                }
                Text(L10n.Settings.VirtualMachine.TartHomeFolder.footer)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.secondary)
            }
        } label: {
            Text(L10n.Settings.VirtualMachine.tartHomeFolder)
        }
        .onChange(of: folderURL) { _ in
            folderPath = folderURL?.path() ?? ""
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
