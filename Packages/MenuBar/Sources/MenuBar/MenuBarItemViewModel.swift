import Combine
import Foundation
import SettingsDomain
import SwiftUI
import VirtualMachineDomain

public final class MenuBarItemViewModel<SettingsStoreType: SettingsStore>: ObservableObject {
    let settingsStore: SettingsStoreType
    var virtualMachinesMenuTitle: String {
        if settingsStore.numberOfVirtualMachines == 1 {
            return L10n.Menu.VirtualMachines.singularis
        } else {
            return L10n.Menu.VirtualMachines.pluralis
        }
    }

    private let fleet: VirtualMachineFleet
    private let editor: VirtualMachineEditor
    private let settingsPresenter = SettingsPresenter()
    private var cancellables: Set<AnyCancellable> = []

    public init(
        settingsStore: SettingsStoreType,
        fleet: VirtualMachineFleet,
        editor: VirtualMachineEditor
    ) {
        self.settingsStore = settingsStore
        self.fleet = fleet
        self.editor = editor
    }

    func presentSettings() {
        settingsPresenter.presentSettings()
    }

    func presentAbout() {
        NSApplication.shared.orderFrontStandardAboutPanel()
        NSApp.activate(ignoringOtherApps: true)
    }

    func quitApp() {
        NSApplication.shared.terminate(nil)
    }

    func makeVirtualMachinesMenuContentViewModel() -> VirtualMachinesMenuContentViewModel<SettingsStoreType> {
        VirtualMachinesMenuContentViewModel(
            settingsStore: settingsStore,
            fleet: fleet,
            editor: editor,
            settingsPresenter: settingsPresenter
        )
    }
}
