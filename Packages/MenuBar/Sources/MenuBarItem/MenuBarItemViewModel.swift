import Combine
import Foundation
import SettingsStore
import SwiftUI
import VirtualMachineEditorService
import VirtualMachineFleet
import VirtualMachineResourcesService

public final class MenuBarItemViewModel: ObservableObject {
    let settingsStore: SettingsStore
    var virtualMachinesMenuTitle: String {
        if settingsStore.numberOfVirtualMachines == 1 {
            return L10n.Menu.VirtualMachines.singularis
        } else {
            return L10n.Menu.VirtualMachines.pluralis
        }
    }

    private let fleet: VirtualMachineFleet
    private let editorService: VirtualMachineEditorService
    private let settingsPresenter = SettingsPresenter()
    private let editorResourcesService: VirtualMachineResourcesService
    private var cancellables: Set<AnyCancellable> = []

    public init(
        settingsStore: SettingsStore,
        fleet: VirtualMachineFleet,
        editorService: VirtualMachineEditorService,
        editorResourcesService: VirtualMachineResourcesService
    ) {
        self.settingsStore = settingsStore
        self.fleet = fleet
        self.editorService = editorService
        self.editorResourcesService = editorResourcesService
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

    func makeVirtualMachinesMenuContentViewModel() -> VirtualMachinesMenuContentViewModel {
        VirtualMachinesMenuContentViewModel(
            settingsStore: settingsStore,
            fleet: fleet,
            editorService: editorService,
            editorResourcesService: editorResourcesService,
            settingsPresenter: settingsPresenter
        )
    }
}
