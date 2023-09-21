import SwiftUI

struct VirtualMachinesMenuContent: View {
    @StateObject private var viewModel: VirtualMachinesMenuContentViewModel

    init(viewModel: VirtualMachinesMenuContentViewModel) {
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
        ).disabled(!viewModel.isEditorMenuBarItemEnabled)
        PresentEditorResourcesMenuBarItem(onSelect: viewModel.openEditorResources)
    }
}
