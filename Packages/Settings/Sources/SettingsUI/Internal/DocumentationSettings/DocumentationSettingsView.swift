import AppKit
import SwiftUI

struct DocumentationSettingsView: View {
    var body: some View {
        Form {
            Section {
                Text(L10n.Settings.Documentation.introduction)
            } footer: {
                HStack {
                    Button {
                        if let url = URL(string: "https://github.com/shapehq/tartelet/wiki") {
                            NSWorkspace.shared.open(url)
                        }
                    } label: {
                        Text(L10n.Settings.Documentation.openDocumentation)
                    }
                    Spacer()
                }
            }
        }
        .formStyle(.grouped)
    }
}
