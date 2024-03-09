import SettingsDomain
import SwiftUI
import VirtualMachineDomain

struct EditorMenuBarItem: View {
    let configurationState: ConfigurationState
    let virtualMachineState: VirtualMachineState
    let onSelect: () -> Void

    private var title: String {
        switch virtualMachineState {
        case .ready, .fleetStarted, .stoppingFleet:
            L10n.MenuBarItem.Editor.EditVirtualMachine.start
        case .editorStarted:
            L10n.MenuBarItem.Editor.EditVirtualMachine.editing
        }
    }
    private var isEnabled: Bool {
        switch (configurationState, virtualMachineState) {
        case (.ready, .ready):
            return true
        case (_, _):
            return false
        }
    }

    var body: some View {
        Button {
            onSelect()
        } label: {
            Text(title)
        }
        .disabled(!isEnabled)
    }
}
