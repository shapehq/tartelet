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
        }.commands {
            CommandMenu(viewModel.virtualMachinesMenuTitle) {
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
    }
}
