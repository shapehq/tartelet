import FileSystemData
import GitHubData
import GitHubDomain
import Keychain
import LoggingData
import MenuBar
import SettingsDomain
import SettingsUI
import Shell
import SwiftUI
import VirtualMachineData
import VirtualMachineDomain

@main
struct TarteletApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    private var settingsStore: some SettingsStore {
        Composers.settingsStore
    }
    private var fleet: VirtualMachineFleet {
        Composers.fleet
    }
    private var editor: VirtualMachineEditor {
        Composers.editor
    }
    private var gitHubCredentialsStore: GitHubCredentialsStore {
        KeychainGitHubCredentialsStore(
            keychain: Keychain(
                logger: OSLogger(subsystem: "GitHubCredentialsStore"),
                accessGroup: "566MC7D8D4.dk.shape.Tartelet"
            ),
            serviceName: "Tartelet GitHub Account"
        )
    }

    var body: some Scene {
        MenuBarItem(
            viewModel: MenuBarItemViewModel(
                settingsStore: settingsStore,
                fleet: fleet,
                editor: editor
            )
        )
        SettingsScene(
            settingsStore: settingsStore,
            gitHubCredentialsStore: gitHubCredentialsStore,
            sourceNameRepository: TartVirtualMachineSourceNameRepository(
                tart: Tart(
                    homeProvider: SettingsTartHomeProvider(
                        settingsStore: settingsStore
                    ),
                    shell: Shell()
                )
            ),
            logExporter: NullObjectLogExporter(),
            fleet: fleet,
            editor: editor
        )
    }
}
