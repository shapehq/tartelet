import FileSystemData
import LoggingData
import MenuBar
import SettingsDomain
import SettingsUI
import ShellData
import SwiftUI
import VirtualMachineData
import VirtualMachineDomain

@main
struct TarteletApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarItem(
            viewModel: MenuBarItemViewModel(
                settingsStore: Composers.settingsStore,
                fleet: Composers.fleet,
                editor: Composers.editor
            )
        )
        SettingsScene(
            settingsStore: Composers.settingsStore,
            gitHubCredentialsStore: Composers.gitHubCredentialsStore,
            sourceNameRepository: TartVirtualMachineSourceNameRepository(
                tart: Tart(
                    homeProvider: SettingsTartHomeProvider(
                        settingsStore: Composers.settingsStore
                    ),
                    shell: ProcessShell()
                )
            ),
            logExporter: FileLogExporter(
                fileSystem: DiskFileSystem()
            ),
            fleet: Composers.fleet,
            editor: Composers.editor
        )
    }
}
