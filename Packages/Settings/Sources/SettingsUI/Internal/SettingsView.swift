import Combine
import GitHubCredentialsStore
import LogExporter
import SettingsStore
import SwiftUI
import VirtualMachineSourceNameRepository

struct SettingsView: View {
    let settingsStore: SettingsStore
    let gitHubCredentialsStore: GitHubCredentialsStore
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
        }.frame(width: 450, height: 250)
    }
}
