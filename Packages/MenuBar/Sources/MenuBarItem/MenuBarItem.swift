import SettingsStore
import SwiftUI

public struct MenuBarItem: Scene {
    @StateObject private var viewModel: MenuBarItemViewModel
    @StateObject private var settingsStore: SettingsStore
    @State private var isInserted: Bool

    public init(viewModel: MenuBarItemViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        isInserted = viewModel.settingsStore.applicationUIMode.showInMenuBar
        _settingsStore = StateObject(wrappedValue: viewModel.settingsStore)
    }

    public var body: some Scene {
        MenuBarExtra(isInserted: $isInserted) {
            VirtualMachineMenuBarItem(
                hasSelectedVirtualMachine: viewModel.hasSelectedVirtualMachine,
                isFleetStarted: viewModel.isFleetStarted,
                isEditorStarted: viewModel.isEditorStarted,
                startsSingleVirtualMachine: settingsStore.numberOfVirtualMachines == 1
            ) {
                if viewModel.isFleetStarted {
                    viewModel.stopFleet()
                } else if viewModel.hasSelectedVirtualMachine {
                    viewModel.startFleet()
                } else {
                    viewModel.presentSettings()
                }
            }
            Divider()
            Button {
                viewModel.startEditor()
            } label: {
                Text(L10n.MenuBarItem.Editor.editVirtualMachine)
            }.disabled(viewModel.isFleetStarted || viewModel.isEditorStarted || !viewModel.hasSelectedVirtualMachine)
            Button {
                viewModel.openEditorResources()
            } label: {
                Text(L10n.MenuBarItem.Editor.openResources)
            }
            Divider()
            Button {
                viewModel.presentSettings()
            } label: {
                Text(L10n.MenuBarItem.settings)
            }.keyboardShortcut(",", modifiers: .command)
            Button {
                viewModel.presentAbout()
            } label: {
                Text(L10n.MenuBarItem.about)
            }
            Divider()
            Button {
                viewModel.quitApp()
            } label: {
                Text(L10n.MenuBarItem.quit)
            }
        } label: {
            Image(systemName: "desktopcomputer")
        }.onChange(of: settingsStore.applicationUIMode) { mode in
            isInserted = mode.showInMenuBar
        }
    }
}
