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

    static let editorService = VirtualMachineEditorService(
        virtualMachineFactory: virtualMachineFactory(
            resourcesService: editorResourcesService
        )
    )

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
        let virtualMachineFactory = virtualMachineFactory(resourcesService: fleetResourcesService)
        return DefaultVirtualMachineFleetFactory(settingsStore: settingsStore, virtualMachineFactory: virtualMachineFactory)
    }

    private static func virtualMachineFactory(resourcesService: VirtualMachineResourcesService) -> VirtualMachineFactory {
        DefaultVirtualMachineFactory(
            tart: tart,
            settingsStore: settingsStore,
            resourcesService: resourcesService
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
