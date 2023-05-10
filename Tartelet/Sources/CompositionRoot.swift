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
import LogConsumer
import LogConsumerOSLog
import LogExporter
import LogExporterLive
import LogStore
import LogStoreOSLog
import MenuBarItem
import NetworkingService
import NetworkingServiceLive
import SettingsStore
import SettingsUI
import Shell
import SwiftUI
import Tart
import TartVirtualMachineSourceNameRepository
import VirtualMachineAutomaticLauncher
import VirtualMachineEditorService
import VirtualMachineFactory
import VirtualMachineFleet
import VirtualMachineFleetLive
import VirtualMachineResourcesCopier
import VirtualMachineResourcesService
import VirtualMachineResourcesServiceEditor
import VirtualMachineSourceNameRepository

enum CompositionRoot {
    static let dock = Dock(showAppInDock: showAppInDockPublisher.rawValue)

    static var virtualMachineAutomaticLauncher: VirtualMachineAutomaticLauncher {
        VirtualMachineAutomaticLauncher(
            logger: logger(withCategory: .virtualMachine),
            settingsStore: settingsStore,
            fleet: fleet
        )
    }

    static let fleet: VirtualMachineFleet = VirtualMachineFleetLive(
        logger: logger(withCategory: .virtualMachine),
        virtualMachineFactory: fleetVirtualMachineFactory
    )

    static let editorService = VirtualMachineEditorService(
        logger: logger(withCategory: .virtualMachine),
        virtualMachineFactory: editorVirtualMachineFactory
    )

    static var menuBarItem: some Scene {
        MenuBarItem(
            viewModel: MenuBarItemViewModel(
                settingsStore: settingsStore,
                fleet: fleet,
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
            logExporter: logExporter,
            fleet: fleet,
            editorService: editorService
        )
    }
}

private extension CompositionRoot {
    private static func logger(withCategory category: LoggerCategory) -> LogConsumer {
        LogConsumerOSLog(category: category.rawValue)
    }

    private static var logExporter: LogExporter {
        LogExporterLive(fileSystem: fileSystem, logStore: logStore)
    }

    private static var logStore: LogStore {
        LogStoreOSLog()
    }

    private static let showAppInDockPublisher = ShowAppInDockPublisher(settingsStore: settingsStore)

    private static var editorVirtualMachineFactory: VirtualMachineFactory {
        LongLivedVirtualMachineFactory(
            logger: logger(withCategory: .virtualMachine),
            tart: tart,
            settingsStore: settingsStore,
            resourcesService: editorResourcesService
        )
    }

    private static var fleetVirtualMachineFactory: VirtualMachineFactory {
        EphemeralVirtualMachineFactory(
            logger: logger(withCategory: .virtualMachine),
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
            settingsStore: settingsStore,
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
        VirtualMachineResourcesCopier(
            logger: logger(withCategory: .virtualMachine),
            fileSystem: fileSystem
        )
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
        KeychainLive(
            logger: logger(withCategory: .keychain),
            accessGroup: "566MC7D8D4.dk.shape.Tartelet"
        )
    }

    private static var networkingService: NetworkingService {
        NetworkingServiceLive(
            logger: logger(withCategory: .networking),
            session: .shared
        )
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
