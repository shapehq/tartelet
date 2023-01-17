import Combine
import SettingsStore
import SwiftUI
import VirtualMachineSourceNameRepository

struct SettingsView: View {
    let settingsStore: SettingsStore
    let virtualMachinesSourceNameRepository: VirtualMachineSourceNameRepository
    let isVirtualMachineSettingsEnabled: AnyPublisher<Bool, Never>

    var body: some View {
        TabView {
            GeneralSettingsView(settingsStore: settingsStore).tabItem {
                Label(L10n.Settings.general, systemImage: "gear")
            }
            VirtualMachineSettingsView(
                viewModel: VirtualMachineSettingsViewModel(
                    settingsStore: settingsStore,
                    virtualMachinesSourceNameRepository: virtualMachinesSourceNameRepository,
                    isVirtualMachineSettingsEnabled: isVirtualMachineSettingsEnabled
                )
            ).tabItem {
                Label(L10n.Settings.virtualMachine, systemImage: "desktopcomputer")
            }
        }.frame(width: 450, height: 250)
    }
}
