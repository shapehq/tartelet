import SettingsDomain
import SwiftUI
import VirtualMachineDomain

struct FleetMenuBarItem: View {
    let configurationState: ConfigurationState
    let virtualMachineState: VirtualMachineState
    let startFleet: () -> Void
    let stopFleet: () -> Void

    var body: some View {
        ContentButton(presentSettings: presentSettings) {
            performAction()
        } label: {
            HStack {
                image
                Text(title)
            }
        }
        if virtualMachineState == .stoppingFleet {
            Button {} label: {
                Text(L10n.MenuBarItem.VirtualMachines.stoppingInfo)
            }
            .disabled(true)
        }
    }
}

private extension FleetMenuBarItem {
    private var title: String {
        switch (configurationState, virtualMachineState) {
        case (.ready, .stoppingFleet):
            return L10n.MenuBarItem.VirtualMachines.stopping
        case (.ready, .fleetStarted):
            return L10n.MenuBarItem.VirtualMachines.stop
        case (.ready, .ready), (.ready, .editorStarted):
            return L10n.MenuBarItem.VirtualMachines.start
        case (_, _):
            return configurationState.shortInstruction
        }
    }

    private var image: Image {
        switch (configurationState, virtualMachineState) {
        case (.ready, .stoppingFleet),
             (.ready, .fleetStarted):
            return Image(systemName: "stop.fill")
        case (.ready, .ready), (.ready, .editorStarted):
            return Image(systemName: "play.fill")
        case (_, _):
            return Image(systemName: "switch.2")
        }
    }

    private var isDisabled: Bool {
        switch virtualMachineState {
        case .stoppingFleet, .editorStarted:
            return true
        case .fleetStarted, .ready:
            return false
        }
    }

    private var presentSettings: Bool {
        switch configurationState {
        case .ready:
            false
        case _:
            true
        }
    }

    private func performAction() {
        switch (configurationState, virtualMachineState) {
        case (.ready, .stoppingFleet), (.ready, .editorStarted):
            break
        case (.ready, .fleetStarted):
            stopFleet()
        case (.ready, .ready):
            startFleet()
        case (_, _):
            break
        }
    }
}

private extension FleetMenuBarItem {
    struct ContentButton<Label: View>: View {
        private let presentSettings: Bool
        private let onSelect: () -> Void
        private let label: () -> Label

        init(
            presentSettings: Bool,
            onSelect: @escaping () -> Void,
            @ViewBuilder label: @escaping () -> Label
        ) {
            self.presentSettings = presentSettings
            self.onSelect = onSelect
            self.label = label
        }

        var body: some View {
            if presentSettings {
                SettingsLink {
                    label()
                }
            } else {
                Button {
                    onSelect()
                } label: {
                    label()
                }
            }
        }
    }
}
