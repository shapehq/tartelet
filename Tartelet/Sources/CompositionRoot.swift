import Combine
import Dock
import FileSystem
import FileSystemDisk
import MenuBarItem
import SettingsStore
import SettingsUI
import Shell
import SwiftUI
import Tart
import TartVirtualMachineSourceNameRepository
import VirtualMachineFactory
import VirtualMachineFleetFactory
import VirtualMachineFleetService
import VirtualMachineResourcesService
import VirtualMachineResourcesServiceFleet
import VirtualMachineSourceNameRepository

enum CompositionRoot {
    static let dock = Dock(showAppInDock: showAppInDockPublisher.rawValue)

    static let virtualMachineFleetService = VirtualMachineFleetService(fleetFactory: virtualMachineFleetFactory)

    static var menuBarItem: some Scene {
        MenuBarItem(
            viewModel: MenuBarItemViewModel(
                settingsStore: settingsStore,
                virtualMachineFleetService: virtualMachineFleetService
            )
        )
    }

    static var settingsWindow: some Scene {
        SettingsScene(
            settingsStore: settingsStore,
            virtualMachinesSourceNameRepository: virtualMachineSourceNameRepository,
            virtualMachineFleetService: virtualMachineFleetService
        )
    }
}

private extension CompositionRoot {
    private static let showAppInDockPublisher = ShowAppInDockPublisher(settingsStore: settingsStore)

    private static var virtualMachineFleetFactory: VirtualMachineFleetFactory {
        DefaultVirtualMachineFleetFactory(settingsStore: settingsStore, virtualMachineFactory: virtualMachineFactory)
    }

    private static var virtualMachineFactory: VirtualMachineFactory {
        DefaultVirtualMachineFactory(
            tart: tart,
            settingsStore: settingsStore,
            resourcesService: virtualMachineResourcesService
        )
    }

    private static var virtualMachineResourcesService: VirtualMachineResourcesService {
        VirtualMachineResourcesServiceFleet(fileSystem: fileSystem)
    }

    private static var virtualMachineSourceNameRepository: VirtualMachineSourceNameRepository {
        TartVirtualMachineSourceNameRepository(tart: tart)
    }

    private static let settingsStore = SettingsStore()

    private static var tart: Tart {
        Tart(shell: shell)
    }

    private static var shell: Shell {
        Shell()
    }

    private static var fileSystem: FileSystem {
        FileSystemDisk()
    }
}
