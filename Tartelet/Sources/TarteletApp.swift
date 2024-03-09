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
            settingsStore: Composers.settingsStore,
            fleet: Composers.fleet,
            editor: Composers.editor
        )
        SettingsScene(
            settingsStore: Composers.settingsStore,
            gitHubCredentialsStore: Composers.gitHubCredentialsStore,
            virtualMachineCredentialsStore: Composers.virtualMachineSSHCredentialsStore,
            virtualMachinesSourceNameRepository: TartVirtualMachineSourceNameRepository(
                tart: Tart(
                    homeProvider: SettingsTartHomeProvider(
                        settingsStore: Composers.settingsStore
                    ),
                    shell: ProcessShell()
                )
            ),
            logExporter: FileLogExporter(
                logger: Composers.logger(subsystem: "FileLogExporter"),
                fileSystem: DiskFileSystem()
            ),
            fleet: Composers.fleet,
            editor: Composers.editor
        )
    }
}
