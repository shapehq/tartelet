import FileSystemData
import GitHubData
import GitHubDomain
import Keychain
import LoggingData
import LoggingDomain
import NetworkingData
import Observation
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
            logger: logger(subsystem: "SSHConnectingVirtualMachine"),
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
                logger: logger(subsystem: "VirtualMachineSSHClient"),
                client: CitadelSSHClient(
                    logger: logger(subsystem: "CitadelSSHClient")
                ),
                ipAddressReader: RetryingVirtualMachineIPAddressReader(),
                credentialsStore: virtualMachineSSHCredentialsStore,
                connectionHandler: GitHubActionsRunnerSSHConnectionHandler(
                    logger: logger(subsystem: "GitHubActionsRunnerSSHConnectionHandler"),
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

    static let gitHubCredentialsStore = KeychainGitHubCredentialsStore(
        keychain: keychain(
            logger: logger(subsystem: "GitHubCredentialsStore")
        ),
        serviceName: "Tartelet GitHub Account"
    )

    static let virtualMachineSSHCredentialsStore = KeychainVirtualMachineSSHCredentialsStore(
        keychain: keychain(
            logger: logger(subsystem: "KeychainVirtualMachineSSHCredentialsStore")
        ),
        serviceName: "Tartelet Virtual Machine SSH Credentials"
    )

    static func logger(subsystem: String) -> Logger {
        FileLogger(
            fileSystem: DiskFileSystem(),
            dateProvider: FoundationDateProvider(),
            subsystem: subsystem,
            daysOfRetention: 7
        )
    }
}

private extension Composers {
    private static func keychain(logger: Logger) -> Keychain {
        Keychain(logger: logger, accessGroup: "566MC7D8D4.dk.shape.Tartelet")
    }
}
