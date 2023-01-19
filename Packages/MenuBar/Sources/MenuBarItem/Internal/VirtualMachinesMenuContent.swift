import SettingsStore
import SwiftUI

struct VirtualMachinesMenuContent: View {
    @StateObject private var viewModel: VirtualMachinesMenuContentViewModel
    @ObservedObject private var settingsStore: SettingsStore

    init(viewModel: VirtualMachinesMenuContentViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _settingsStore = ObservedObject(wrappedValue: viewModel.settingsStore)
    }

    var body: some View {
        FleetMenuBarItem(
            hasSelectedVirtualMachine: viewModel.hasSelectedVirtualMachine,
            isFleetStarted: viewModel.isFleetStarted,
            isEditorStarted: viewModel.isEditorStarted,
            startsSingleVirtualMachine: settingsStore.numberOfVirtualMachines == 1,
            onSelect: viewModel.presentFleet
        )
        Divider()
        EditorMenuBarItem(
            isEditorStarted: viewModel.isEditorStarted,
            onSelect: viewModel.startEditor
        ).disabled(!viewModel.isEditorMenuBarItemEnabled)
        PresentEditorResourcesMenuBarItem(onSelect: viewModel.openEditorResources)
    }
}
