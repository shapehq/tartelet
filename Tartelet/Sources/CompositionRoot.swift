import Combine
import Dock
import FileSystem
import FileSystemDisk
import GitHubCredentialsStore
import GitHubCredentialsStoreKeychain
import GitHubService
import GitHubServiceLive
import Keychain
import KeychainLive
import MenuBarItem
import NetworkingService
import NetworkingServiceLive
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
import VirtualMachineResourcesCopier
import VirtualMachineResourcesService
import VirtualMachineResourcesServiceEditor
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
            gitHubCredentialsStore: gitHubCredentialsStore,
            sourceNameRepository: virtualMachineSourceNameRepository,
            fleetService: fleetService,
            editorService: editorService
        )
    }
}

private extension CompositionRoot {
    private static let showAppInDockPublisher = ShowAppInDockPublisher(settingsStore: settingsStore)

    private static var fleetFactory: VirtualMachineFleetFactory {
        DefaultVirtualMachineFleetFactory(settingsStore: settingsStore, virtualMachineFactory: fleetVirtualMachineFactory)
    }

    private static var editorVirtualMachineFactory: VirtualMachineFactory {
        LongLivedVirtualMachineFactory(
            tart: tart,
            settingsStore: settingsStore,
            resourcesService: editorResourcesService
        )
    }

    private static var fleetVirtualMachineFactory: VirtualMachineFactory {
        EphemeralVirtualMachineFactory(
            tart: tart,
            settingsStore: settingsStore,
            resourcesServiceFactory: ephemeralVirtualMachineResourcesServiceFactory
        )
    }

    private static var editorResourcesService: VirtualMachineResourcesService {
        VirtualMachineResourcesServiceEditor(fileSystem: fileSystem, resourcesCopier: virtualMachineResourcesCopier)
    }

    private static var ephemeralVirtualMachineResourcesServiceFactory: VirtualMachineResourcesServiceFactory {
        EphemeralVirtualMachineResourcesServiceFactory(
            fileSystem: fileSystem,
            gitHubService: gitHubService,
            gitHubCredentialsStore: gitHubCredentialsStore,
            resourcesCopier: virtualMachineResourcesCopier,
            editorResourcesDirectoryURL: editorResourcesService.directoryURL
        )
    }

    private static var virtualMachineSourceNameRepository: VirtualMachineSourceNameRepository {
        TartVirtualMachineSourceNameRepository(tart: tart)
    }

    private static var virtualMachineResourcesCopier: VirtualMachineResourcesCopier {
        VirtualMachineResourcesCopier(fileSystem: fileSystem)
    }

    private static var gitHubService: GitHubService {
        GitHubServiceLive(
            credentialsStore: gitHubCredentialsStore,
            networkingService: networkingService
        )
    }

    private static var gitHubCredentialsStore: GitHubCredentialsStore {
        GitHubCredentialsStoreKeychain(keychain: keychain, serviceName: "Tartelet GitHub Account")
    }

    private static var keychain: Keychain {
        KeychainLive(accessGroup: "566MC7D8D4.dk.shape.Tartelet")
    }

    private static var networkingService: NetworkingService {
        NetworkingServiceLive(session: .shared)
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
