import SwiftUI

struct VirtualMachineMenuBarItem: View {
    let hasSelectedVirtualMachine: Bool
    let isFleetStarted: Bool
    let isEditorStarted: Bool
    let startsSingleVirtualMachine: Bool
    let onSelect: () -> Void

    var body: some View {
        if isFleetStarted {
            Button {
                onSelect()
            } label: {
                HStack {
                    Image(systemName: "stop.fill")
                    if startsSingleVirtualMachine {
                        Text(L10n.MenuBarItem.VirtualMachines.Stop.singularis)
                    } else {
                        Text(L10n.MenuBarItem.VirtualMachines.Stop.pluralis)
                    }
                }
            }
        } else if hasSelectedVirtualMachine {
            Button {
                onSelect()
            } label: {
                HStack {
                    Image(systemName: "play.fill")
                    if startsSingleVirtualMachine {
                        Text(L10n.MenuBarItem.VirtualMachines.Start.singularis)
                    } else {
                        Text(L10n.MenuBarItem.VirtualMachines.Start.pluralis)
                    }
                }
            }.disabled(isEditorStarted)
        } else {
            Button {
                onSelect()
            } label: {
                HStack {
                    Image(systemName: "desktopcomputer")
                    Text(L10n.MenuBarItem.VirtualMachines.unavailable)
                }
            }
        }
    }
}
