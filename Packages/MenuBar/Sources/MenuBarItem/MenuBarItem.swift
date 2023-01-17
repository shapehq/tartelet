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
                canStartFleet: viewModel.canStartFleet,
                isFleetStarted: viewModel.isFleetStarted,
                startsSingleVirtualMachine: settingsStore.numberOfVirtualMachines == 1
            ) {
                if viewModel.isFleetStarted {
                    viewModel.stopVirtualMachines()
                } else if viewModel.canStartFleet {
                    viewModel.startVirtualMachines()
                } else {
                    viewModel.presentSettings()
                }
            }
            Divider()
            Button {

            } label: {
                Text(L10n.MenuBarItem.editVirtualMachine)
            }
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
