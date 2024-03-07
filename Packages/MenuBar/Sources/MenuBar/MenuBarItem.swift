import SettingsDomain
import SwiftUI

public struct MenuBarItem<SettingsStoreType: SettingsStore>: Scene {
    @StateObject private var viewModel: MenuBarItemViewModel<SettingsStoreType>
    @ObservedObject private var settingsStore: SettingsStoreType
    @State private var isInserted: Bool

    public init(viewModel: MenuBarItemViewModel<SettingsStoreType>) {
        _viewModel = StateObject(wrappedValue: viewModel)
        isInserted = viewModel.settingsStore.applicationUIMode.showInMenuBar
        _settingsStore = ObservedObject(wrappedValue: viewModel.settingsStore)
    }

    public var body: some Scene {
        MenuBarExtra(isInserted: $isInserted) {
            VirtualMachinesMenuContent(viewModel: viewModel.makeVirtualMachinesMenuContentViewModel())
            Divider()
            if #available(macOS 14, *) {
                SettingsLink {
                    Text(L10n.MenuBarItem.settings)
                }.keyboardShortcut(",", modifiers: .command)
            } else {
                Button {
                    viewModel.presentSettings()
                } label: {
                    Text(L10n.MenuBarItem.settings)
                }.keyboardShortcut(",", modifiers: .command)
            }
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
