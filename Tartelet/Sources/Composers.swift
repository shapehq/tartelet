import FileSystemData
import GitHubData
import GitHubDomain
import Keychain
import LoggingData
import LoggingDomain
import NetworkingData
import SettingsData
import ShellData
import SSHData
import VirtualMachineData
import VirtualMachineDomain

enum Composers {
    static let settingsStore = AppStorageSettingsStore()

    static let fleet = VirtualMachineFleet(
        logger: logger(subsystem: "VirtualMachineFleet"),
        baseVirtualMachine: SSHConnectingVirtualMachine(
            virtualMachine: SettingsVirtualMachine(
                tart: Tart(
                    homeProvider: SettingsTartHomeProvider(
                        settingsStore: settingsStore
                    ),
                    shell: ProcessShell()
                ),
                settingsStore: settingsStore
            ),
            sshClient: VirtualMachineSSHClient(
                client: CitadelSSHClient(
                    logger: logger(subsystem: "SSH")
                ),
                ipAddressReader: RetryingVirtualMachineIPAddressReader(),
                credentials: SettingsVirtualMachineSSHCredentials(
                    settingsStore: settingsStore
                ),
                connectionHandler: GitHubActionsRunnerSSHConnectionHandler(
                    client: NetworkingGitHubClient(
                        credentialsStore: gitHubCredentialsStore,
                        networkingService: URLSessionNetworkingService(
                            logger: logger(subsystem: "URLSessionNetworkingService")
                        )
                    ),
                    credentialsStore: gitHubCredentialsStore,
                    configuration: SettingsGitHubActionsRunnerConfiguration(
                        settingsStore: settingsStore
                    )
                )
            )
        )
    )

    static let editor = VirtualMachineEditor(
        logger: logger(subsystem: "VirtualMachineEditor"),
        virtualMachine: SettingsVirtualMachine(
            tart: Tart(
                homeProvider: SettingsTartHomeProvider(
                    settingsStore: settingsStore
                ),
                shell: ProcessShell()
            ),
            settingsStore: settingsStore
        )
    )

    static var gitHubCredentialsStore: GitHubCredentialsStore {
        KeychainGitHubCredentialsStore(
            keychain: Keychain(
                logger: logger(subsystem: "GitHubCredentialsStore"),
                accessGroup: "566MC7D8D4.dk.shape.Tartelet"
            ),
            serviceName: "Tartelet GitHub Account"
        )
    }
}

private extension Composers {
    private static func logger(subsystem: String) -> Logger {
        FileLogger(
            fileSystem: DiskFileSystem(),
            dateProvider: FoundationDateProvider(),
            subsystem: subsystem,
            daysOfRetention: 7
        )
    }
}
