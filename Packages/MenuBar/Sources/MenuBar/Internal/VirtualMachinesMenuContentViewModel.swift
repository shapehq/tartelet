import Combine
import Foundation
import SettingsDomain
import SwiftUI
import VirtualMachineDomain

final class VirtualMachinesMenuContentViewModel<SettingsStoreType: SettingsStore>: ObservableObject {
    let settingsStore: SettingsStoreType
    @Published private(set) var hasSelectedVirtualMachine: Bool
    @Published private(set) var isFleetStarted = false
    @Published private(set) var isStoppingFleet = false
    @Published private(set) var isEditorStarted = false
    var isEditorMenuBarItemEnabled: Bool {
        return !isFleetStarted && !isEditorStarted && hasSelectedVirtualMachine
    }

    private let fleet: VirtualMachineFleet
    private let editor: VirtualMachineEditor
    private let settingsPresenter: SettingsPresenter
    private var cancellables: Set<AnyCancellable> = []

    init(
        settingsStore: SettingsStoreType,
        fleet: VirtualMachineFleet,
        editor: VirtualMachineEditor,
        settingsPresenter: SettingsPresenter
    ) {
        self.settingsStore = settingsStore
        self.fleet = fleet
        self.editor = editor
        self.settingsPresenter = settingsPresenter
        self.hasSelectedVirtualMachine = settingsStore.virtualMachine != .unknown
        settingsStore.onChange
            .map { $0.virtualMachine != .unknown }
            .assign(to: \.hasSelectedVirtualMachine, on: self)
            .store(in: &cancellables)
        fleet.isStarted
            .receive(on: DispatchQueue.main)
            .assign(to: \.isFleetStarted, on: self)
            .store(in: &cancellables)
        fleet.isStopping
            .receive(on: DispatchQueue.main)
            .assign(to: \.isStoppingFleet, on: self)
            .store(in: &cancellables)
        editor.isStarted
            .assign(to: \.isEditorStarted, on: self)
            .store(in: &cancellables)
    }

    func startFleet() {
        guard !isFleetStarted else {
            return
        }
        do {
            try fleet.start(numberOfMachines: settingsStore.numberOfVirtualMachines)
        } catch {
            #if DEBUG
            print(error)
            #endif
        }
    }

    func stopFleet() {
        if isFleetStarted {
            fleet.stop()
        }
    }

    func presentSettings() {
        settingsPresenter.presentSettings()
    }

    func startEditor() {
        if !isEditorStarted {
            editor.start()
        }
    }
}
