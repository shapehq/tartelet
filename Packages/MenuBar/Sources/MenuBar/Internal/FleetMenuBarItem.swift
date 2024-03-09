import SwiftUI

struct FleetMenuBarItem: View {
    let hasSelectedVirtualMachine: Bool
    let isFleetStarted: Bool
    let isStoppingFleet: Bool
    let isEditorStarted: Bool
    let startFleet: () -> Void
    let stopFleet: () -> Void

    var body: some View {
        if isStoppingFleet {
            Button {} label: {
                HStack {
                    Image(systemName: "stop.fill")
                    Text(L10n.MenuBarItem.VirtualMachines.stopping)
                }
            }.disabled(true)
            Button {} label: {
                Text(L10n.MenuBarItem.VirtualMachines.stoppingInfo)
            }.disabled(true)
        } else if isFleetStarted {
            Button {
                stopFleet()
            } label: {
                HStack {
                    Image(systemName: "stop.fill")
                    Text(L10n.MenuBarItem.VirtualMachines.stop)
                }
            }
        } else if hasSelectedVirtualMachine {
            Button {
                startFleet()
            } label: {
                HStack {
                    Image(systemName: "play.fill")
                    Text(L10n.MenuBarItem.VirtualMachines.start)
                }
            }.disabled(isEditorStarted)
        } else {
            Button {
                startFleet()
            } label: {
                HStack {
                    Image(systemName: "desktopcomputer")
                    Text(L10n.MenuBarItem.VirtualMachines.unavailable)
                }
            }
        }
    }
}
