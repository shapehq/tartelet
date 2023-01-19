import SettingsStore
import SwiftUI

public struct MenuBarItem: Scene {
    @StateObject private var viewModel: MenuBarItemViewModel
    @ObservedObject private var settingsStore: SettingsStore
    @State private var isInserted: Bool

    public init(viewModel: MenuBarItemViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        isInserted = viewModel.settingsStore.applicationUIMode.showInMenuBar
        _settingsStore = ObservedObject(wrappedValue: viewModel.settingsStore)
    }

    public var body: some Scene {
        MenuBarExtra(isInserted: $isInserted) {
            VirtualMachinesMenuContent(viewModel: viewModel.makeVirtualMachinesMenuContentViewModel())
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
                VirtualMachinesMenuContent(viewModel: viewModel.makeVirtualMachinesMenuContentViewModel())
            }
        }
    }
}
