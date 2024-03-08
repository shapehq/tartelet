import Combine
import GitHubDomain
import LoggingDomain
import SettingsDomain
import SwiftUI
import VirtualMachineDomain

struct SettingsView<SettingsStoreType: SettingsStore>: View {
    let settingsStore: SettingsStoreType
    let gitHubCredentialsStore: GitHubCredentialsStore
    let virtualMachineCredentialsStore: VirtualMachineSSHCredentialsStore
    let virtualMachinesSourceNameRepository: VirtualMachineSourceNameRepository
    let logExporter: LogExporter
    let isVirtualMachineSettingsEnabled: AnyPublisher<Bool, Never>

    var body: some View {
        TabView {
            GeneralSettingsView(
                viewModel: GeneralSettingsViewModel(
                    settingsStore: settingsStore,
                    logExporter: logExporter
                )
            ).tabItem {
                Label(L10n.Settings.general, systemImage: "gear")
            }
            VirtualMachineSettingsView(
                viewModel: VirtualMachineSettingsViewModel(
                    settingsStore: settingsStore,
                    virtualMachinesSourceNameRepository: virtualMachinesSourceNameRepository,
                    credentialsStore: virtualMachineCredentialsStore,
                    isSettingsEnabled: isVirtualMachineSettingsEnabled
                )
            ).tabItem {
                Label(L10n.Settings.virtualMachine, systemImage: "desktopcomputer")
            }
            GitHubSettingsView(
                viewModel: GitHubSettingsViewModel(
                    settingsStore: settingsStore,
                    credentialsStore: gitHubCredentialsStore,
                    isSettingsEnabled: isVirtualMachineSettingsEnabled
                )
            ).tabItem {
                Label {
                    Text(L10n.Settings.github)
                } icon: {
                    Asset.github.swiftUIImage
                }
            }
            GitHubRunnerSettingsView(
                viewModel: GitHubRunnerSettingsViewModel(
                    settingsStore: settingsStore,
                    isSettingsEnabled: isVirtualMachineSettingsEnabled
                )
            ).tabItem {
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
