import Combine
import Foundation
import SettingsStore
import SwiftUI
import VirtualMachineFleetService

public final class MenuBarItemViewModel: ObservableObject {
    let settingsStore: SettingsStore
    @Published private(set) var canStartFleet: Bool
    @Published private(set) var isFleetStarted = false

    private let virtualMachineFleetService: VirtualMachineFleetService
    private var cancellables: Set<AnyCancellable> = []

    public init(settingsStore: SettingsStore, virtualMachineFleetService: VirtualMachineFleetService) {
        self.settingsStore = settingsStore
        self.virtualMachineFleetService = virtualMachineFleetService
        self.canStartFleet = settingsStore.virtualMachine != .unknown
        settingsStore.onChange.map { $0.virtualMachine != .unknown }.assign(to: \.canStartFleet, on: self).store(in: &cancellables)
        virtualMachineFleetService.isStarted.assign(to: \.isFleetStarted, on: self).store(in: &cancellables)
    }

    func startVirtualMachines() {
        guard !isFleetStarted && canStartFleet else {
            return
        }
        do {
            try virtualMachineFleetService.start()
        } catch {
            #if DEBUG
            print(error)
            #endif
        }
    }

    func stopVirtualMachines() {
        if isFleetStarted {
            virtualMachineFleetService.stop()
        }
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
