import Combine
import Foundation
import SettingsStore
import SwiftUI
import VirtualMachineEditorService
import VirtualMachineFleetService
import VirtualMachineResourcesService

public final class MenuBarItemViewModel: ObservableObject {
    let settingsStore: SettingsStore
    @Published private(set) var hasSelectedVirtualMachine: Bool
    @Published private(set) var isFleetStarted = false
    @Published private(set) var isEditorStarted = false
    var isEditorMenuBarItemEnabled: Bool {
        return !isFleetStarted && !isEditorStarted && hasSelectedVirtualMachine
    }
    var virtualMachinesMenuTitle: String {
        if settingsStore.numberOfVirtualMachines == 1 {
            return L10n.Menu.VirtualMachines.singularis
        } else {
            return L10n.Menu.VirtualMachines.pluralis
        }
    }

    private let fleetService: VirtualMachineFleetService
    private let editorService: VirtualMachineEditorService
    private let editorResourcesService: VirtualMachineResourcesService
    private var cancellables: Set<AnyCancellable> = []

    public init(
        settingsStore: SettingsStore,
        fleetService: VirtualMachineFleetService,
        editorService: VirtualMachineEditorService,
        editorResourcesService: VirtualMachineResourcesService
    ) {
        self.settingsStore = settingsStore
        self.fleetService = fleetService
        self.editorService = editorService
        self.editorResourcesService = editorResourcesService
        self.hasSelectedVirtualMachine = settingsStore.virtualMachine != .unknown
        settingsStore.onChange.map { $0.virtualMachine != .unknown }.assign(to: \.hasSelectedVirtualMachine, on: self).store(in: &cancellables)
        fleetService.isStarted.assign(to: \.isFleetStarted, on: self).store(in: &cancellables)
        editorService.isStarted.assign(to: \.isEditorStarted, on: self).store(in: &cancellables)
    }

    func presentFleet() {
        if isFleetStarted {
            stopFleet()
        } else if hasSelectedVirtualMachine {
            startFleet()
        } else {
            presentSettings()
        }
    }

    func startEditor() {
        if !isEditorStarted {
            editorService.start()
        }
    }

    func openEditorResources() {
        do {
            try editorResourcesService.createResourcesIfNeeded()
            try editorResourcesService.openDirectory()
        } catch {}
    }

    func presentAbout() {
        NSApplication.shared.orderFrontStandardAboutPanel()
        NSApp.activate(ignoringOtherApps: true)
    }

    func presentSettings() {
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}

private extension MenuBarItemViewModel {
    private func startFleet() {
        guard !isFleetStarted && hasSelectedVirtualMachine else {
            return
        }
        do {
            try fleetService.start()
        } catch {
            #if DEBUG
            print(error)
            #endif
        }
    }

    private func stopFleet() {
        if isFleetStarted {
            fleetService.stop()
        }
    }
}
