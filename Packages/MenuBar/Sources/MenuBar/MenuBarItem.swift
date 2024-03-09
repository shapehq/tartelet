import SettingsDomain
import SwiftUI
import VirtualMachineDomain

public struct MenuBarItem<SettingsStoreType: SettingsStore>: Scene {
    @State private var isInserted: Bool
    private let settingsStore: SettingsStoreType
    private let fleet: VirtualMachineFleet
    private let editor: VirtualMachineEditor
    private var virtualMachinesMenuTitle: String {
        if settingsStore.numberOfVirtualMachines == 1 {
            L10n.Menu.VirtualMachines.singularis
        } else {
            L10n.Menu.VirtualMachines.pluralis
        }
    }

    public init(
        settingsStore: SettingsStoreType,
        fleet: VirtualMachineFleet,
        editor: VirtualMachineEditor
    ) {
        self.settingsStore = settingsStore
        self.fleet = fleet
        self.editor = editor
        self.isInserted = settingsStore.applicationUIMode.showInMenuBar
    }

    public var body: some Scene {
        MenuBarExtra(isInserted: $isInserted) {
            makeVirtualMachinesMenuContent()
            Divider()
            if #available(macOS 14, *) {
                SettingsLink {
                    Text(L10n.MenuBarItem.settings)
                }.keyboardShortcut(",", modifiers: .command)
            } else {
                Button {
                    SettingsPresenter.presentSettings()
                } label: {
                    Text(L10n.MenuBarItem.settings)
                }.keyboardShortcut(",", modifiers: .command)
            }
            Button {
                presentAbout()
            } label: {
                Text(L10n.MenuBarItem.about)
            }
            Divider()
            Button {
                quitApp()
            } label: {
                Text(L10n.MenuBarItem.quit)
            }
        } label: {
            Image(systemName: "desktopcomputer")
        }
        .onChange(of: settingsStore.applicationUIMode) { _, newValue in
            isInserted = newValue.showInMenuBar
        }
        .commands {
            CommandMenu(virtualMachinesMenuTitle) {
                makeVirtualMachinesMenuContent()
            }
        }
    }
}

private extension MenuBarItem {
    private func presentAbout() {
        NSApplication.shared.orderFrontStandardAboutPanel()
        NSApp.activate(ignoringOtherApps: true)
    }

    private func quitApp() {
        NSApplication.shared.terminate(nil)
    }

    @ViewBuilder
    private func makeVirtualMachinesMenuContent() -> some View {
        VirtualMachinesMenuContent(
            settingsStore: settingsStore,
            fleet: fleet,
            editor: editor
        )
    }
}
