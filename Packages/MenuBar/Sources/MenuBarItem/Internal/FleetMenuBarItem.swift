import SwiftUI

struct FleetMenuBarItem: View {
    enum Action {
        case start
        case stop
    }

    let hasSelectedVirtualMachine: Bool
    let isFleetStarted: Bool
    let isStoppingFleet: Bool
    let isEditorStarted: Bool
    let onSelect: (Action) -> Void

    var body: some View {
        if isFleetStarted {
            Button {
                onSelect(.stop)
            } label: {
                HStack {
                    Image(systemName: "stop.fill")
                    if isStoppingFleet {
                        Text(L10n.MenuBarItem.VirtualMachines.stopping)
                    } else {
                        Text(L10n.MenuBarItem.VirtualMachines.stop)
                    }
                }
            }.disabled(isStoppingFleet)
        } else if hasSelectedVirtualMachine {
            Button {
                onSelect(.start)
            } label: {
                HStack {
                    Image(systemName: "play.fill")
                    Text(L10n.MenuBarItem.VirtualMachines.start)
                }
            }.disabled(isEditorStarted)
        } else {
            Button {
                onSelect(.start)
            } label: {
                HStack {
                    Image(systemName: "desktopcomputer")
                    Text(L10n.MenuBarItem.VirtualMachines.unavailable)
                }
            }
        }
    }
}
