import SwiftUI

struct EditorMenuBarItem: View {
    let isEditorStarted: Bool
    let onSelect: () -> Void

    var body: some View {
        Button {
            onSelect()
        } label: {
            if isEditorStarted {
                Text(L10n.MenuBarItem.Editor.EditVirtualMachine.editing)
            } else {
                Text(L10n.MenuBarItem.Editor.EditVirtualMachine.start)
            }
        }
    }
}
