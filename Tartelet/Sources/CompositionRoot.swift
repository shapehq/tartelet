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
import VirtualMachineEditorService
import VirtualMachineFactory
import VirtualMachineFleetFactory
import VirtualMachineFleetService
import VirtualMachineResourcesService
import VirtualMachineResourcesServiceEditor
import VirtualMachineResourcesServiceFleet
import VirtualMachineSourceNameRepository

enum CompositionRoot {
    static let dock = Dock(showAppInDock: showAppInDockPublisher.rawValue)

    static let fleetService = VirtualMachineFleetService(fleetFactory: fleetFactory)

    static let editorService = VirtualMachineEditorService(virtualMachineFactory: editorVirtualMachineFactory)

    static var menuBarItem: some Scene {
        MenuBarItem(
            viewModel: MenuBarItemViewModel(
                settingsStore: settingsStore,
                fleetService: fleetService,
                editorService: editorService,
                editorResourcesService: editorResourcesService
            )
        )
    }

    static var settingsWindow: some Scene {
        SettingsScene(
            settingsStore: settingsStore,
            sourceNameRepository: virtualMachineSourceNameRepository,
            fleetService: fleetService,
            editorService: editorService
        )
    }
}

private extension CompositionRoot {
    private static let showAppInDockPublisher = ShowAppInDockPublisher(settingsStore: settingsStore)

    private static var fleetFactory: VirtualMachineFleetFactory {
        return DefaultVirtualMachineFleetFactory(settingsStore: settingsStore, virtualMachineFactory: fleetVirtualMachineFactory)
    }

    private static var editorVirtualMachineFactory: VirtualMachineFactory {
        LongLivedVirtualMachineFactory(
            tart: tart,
            settingsStore: settingsStore,
            resourcesDirectoryURL: editorResourcesService.directoryURL
        )
    }

    private static var fleetVirtualMachineFactory: VirtualMachineFactory {
        EphemeralVirtualMachineFactory(
            tart: tart,
            settingsStore: settingsStore,
            resourcesDirectoryURL: fleetResourcesService.directoryURL
        )
    }

    private static var editorResourcesService: VirtualMachineResourcesService {
        VirtualMachineResourcesServiceEditor(fileSystem: fileSystem)
    }

    private static var fleetResourcesService: VirtualMachineResourcesService {
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
