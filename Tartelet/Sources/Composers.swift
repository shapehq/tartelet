import GitHubData
import GitHubDomain
import Keychain
import LoggingData
import NetworkingData
import SettingsData
import ShellData
import SSHData
import VirtualMachineData
import VirtualMachineDomain

enum Composers {
    static let settingsStore = AppStorageSettingsStore()

    static let fleet = VirtualMachineFleet(
        logger: OSLogger(subsystem: "VirtualMachineFleet"),
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
                client: CitadelSSHClient(),
                ipAddressReader: RetryingVirtualMachineIPAddressReader(),
                credentials: SettingsVirtualMachineSSHCredentials(
                    settingsStore: settingsStore
                ),
                connectionHandler: GitHubActionsRunnerSSHConnectionHandler(
                    client: NetworkingGitHubClient(
                        credentialsStore: gitHubCredentialsStore,
                        networkingService: URLSessionNetworkingService(
                            logger: OSLogger(subsystem: "URLSessionNetworkingService")
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
        logger: OSLogger(subsystem: "VirtualMachineEditor"),
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
                logger: OSLogger(subsystem: "GitHubCredentialsStore"),
                accessGroup: "566MC7D8D4.dk.shape.Tartelet"
            ),
            serviceName: "Tartelet GitHub Account"
        )
    }
}
