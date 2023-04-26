import Combine
import Foundation
import SettingsStore
import SwiftUI
import VirtualMachineEditorService
import VirtualMachineFleet
import VirtualMachineResourcesService

final class VirtualMachinesMenuContentViewModel: ObservableObject {
    let settingsStore: SettingsStore
    @Published private(set) var hasSelectedVirtualMachine: Bool
    @Published private(set) var isFleetStarted = false
    @Published private(set) var isEditorStarted = false
    var isEditorMenuBarItemEnabled: Bool {
        return !isFleetStarted && !isEditorStarted && hasSelectedVirtualMachine
    }

    private let fleet: VirtualMachineFleet
    private let editorService: VirtualMachineEditorService
    private let editorResourcesService: VirtualMachineResourcesService
    private let settingsPresenter: SettingsPresenter
    private var cancellables: Set<AnyCancellable> = []

    init(
        settingsStore: SettingsStore,
        fleet: VirtualMachineFleet,
        editorService: VirtualMachineEditorService,
        editorResourcesService: VirtualMachineResourcesService,
        settingsPresenter: SettingsPresenter
    ) {
        self.settingsStore = settingsStore
        self.fleet = fleet
        self.editorService = editorService
        self.editorResourcesService = editorResourcesService
        self.settingsPresenter = settingsPresenter
        self.hasSelectedVirtualMachine = settingsStore.virtualMachine != .unknown
        settingsStore.onChange.map { $0.virtualMachine != .unknown }.assign(to: \.hasSelectedVirtualMachine, on: self).store(in: &cancellables)
        fleet.isStarted.assign(to: \.isFleetStarted, on: self).store(in: &cancellables)
        editorService.isStarted.assign(to: \.isEditorStarted, on: self).store(in: &cancellables)
    }

    func presentFleet() {
        if isFleetStarted {
            stopFleet()
        } else if hasSelectedVirtualMachine {
            startFleet()
        } else {
            settingsPresenter.presentSettings()
        }
    }

    func startEditor() {
        if !isEditorStarted {
            editorService.start()
        }
    }

    func openEditorResources() {
        Task {
            do {
                try await editorResourcesService.createResourcesIfNeeded()
                try editorResourcesService.openDirectory()
            } catch {}
        }
    }
}

private extension VirtualMachinesMenuContentViewModel {
    private func startFleet() {
        guard !isFleetStarted && hasSelectedVirtualMachine else {
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

    private func stopFleet() {
        if isFleetStarted {
            fleet.stop()
        }
    }
}
