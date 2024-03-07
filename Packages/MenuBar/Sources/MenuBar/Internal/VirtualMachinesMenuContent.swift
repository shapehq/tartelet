import SettingsDomain
import SwiftUI

struct VirtualMachinesMenuContent<SettingsStoreType: SettingsStore>: View {
    @StateObject private var viewModel: VirtualMachinesMenuContentViewModel<SettingsStoreType>

    init(viewModel: VirtualMachinesMenuContentViewModel<SettingsStoreType>) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        FleetMenuBarItem(
            hasSelectedVirtualMachine: viewModel.hasSelectedVirtualMachine,
            isFleetStarted: viewModel.isFleetStarted,
            isStoppingFleet: viewModel.isStoppingFleet,
            isEditorStarted: viewModel.isEditorStarted
        ) { action in
            switch action {
            case .start:
                if viewModel.hasSelectedVirtualMachine {
                    viewModel.startFleet()
                } else {
                    viewModel.presentSettings()
                }
            case .stop:
                viewModel.stopFleet()
            }
        }
        Divider()
        EditorMenuBarItem(
            isEditorStarted: viewModel.isEditorStarted,
            onSelect: viewModel.startEditor
        )
        .disabled(!viewModel.isEditorMenuBarItemEnabled)
    }
}
