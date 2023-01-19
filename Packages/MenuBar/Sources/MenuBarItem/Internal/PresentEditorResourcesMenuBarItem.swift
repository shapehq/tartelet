import SwiftUI

struct PresentEditorResourcesMenuBarItem: View {
    let onSelect: () -> Void

    var body: some View {
        Button {
            onSelect()
        } label: {
            Text(L10n.MenuBarItem.Editor.openResources)
        }
    }
}
