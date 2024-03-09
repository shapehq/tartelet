import SettingsDomain
import SwiftUI
import VirtualMachineDomain

struct VirtualMachinesMenuContent<SettingsStoreType: SettingsStore>: View {
    let settingsStore: SettingsStoreType
    let fleet: VirtualMachineFleet
    let editor: VirtualMachineEditor

    private var hasSelectedVirtualMachine: Bool {
        switch settingsStore.virtualMachine {
        case .virtualMachine:
            return true
        case .unknown:
            return false
        }
    }
    private var isEditorMenuBarItemEnabled: Bool {
        !fleet.isStarted && !editor.isStarted && hasSelectedVirtualMachine
    }

    var body: some View {
        FleetMenuBarItem(
            hasSelectedVirtualMachine: hasSelectedVirtualMachine,
            isFleetStarted: fleet.isStarted,
            isStoppingFleet: fleet.isStopping,
            isEditorStarted: editor.isStarted,
            startFleet: {
                if hasSelectedVirtualMachine {
                    startFleet()
                } else {
                    SettingsPresenter.presentSettings()
                }
            },
            stopFleet: {
                fleet.stop()
            }
        )
        Divider()
        EditorMenuBarItem(isEditorStarted: editor.isStarted) {
            editor.start()
        }
        .disabled(!isEditorMenuBarItemEnabled)
    }
}

private extension VirtualMachinesMenuContent {
    private func startFleet() {
        do {
            try fleet.start(numberOfMachines: settingsStore.numberOfVirtualMachines)
        } catch {
            #if DEBUG
            print(error)
            #endif
        }
    }
}
