import GitHubDomain
import LoggingDomain
import Observation
import SettingsDomain
import SwiftUI
import VirtualMachineDomain

struct SettingsView<SettingsStoreType: SettingsStore & Observable>: View {
    let settingsStore: SettingsStoreType
    let gitHubCredentialsStore: GitHubCredentialsStore
    let virtualMachineSSHCredentialsStore: VirtualMachineSSHCredentialsStore
    let virtualMachinesSourceNameRepository: VirtualMachineSourceNameRepository
    let logExporter: LogExporter
    let isSettingsEnabled: Bool

    var body: some View {
        TabView {
            GeneralSettingsView(
                settingsStore: settingsStore,
                logExporter: logExporter
            )
            .tabItem {
                Label(L10n.Settings.general, systemImage: "gear")
            }
            VirtualMachineSettingsView(
                settingsStore: settingsStore,
                credentialsStore: virtualMachineSSHCredentialsStore,
                virtualMachinesSourceNameRepository: virtualMachinesSourceNameRepository,
                isSettingsEnabled: isSettingsEnabled
            )
            .tabItem {
                Label(L10n.Settings.virtualMachine, systemImage: "desktopcomputer")
            }
            GitHubSettingsView(
                settingsStore: settingsStore,
                credentialsStore: gitHubCredentialsStore,
                isSettingsEnabled: isSettingsEnabled
            )
            .tabItem {
                Label {
                    Text(L10n.Settings.github)
                } icon: {
                    Asset.github.swiftUIImage
                }
            }
            GitHubRunnerSettingsView(
                settingsStore: settingsStore,
                isSettingsEnabled: isSettingsEnabled
            )
            .tabItem {
                Label {
                    Text(L10n.Settings.githubRunner)
                } icon: {
                    Asset.githubActions.swiftUIImage
                }
            }
        }
        .frame(minWidth: 450, maxWidth: 650, minHeight: 250, maxHeight: 450)
    }
}
