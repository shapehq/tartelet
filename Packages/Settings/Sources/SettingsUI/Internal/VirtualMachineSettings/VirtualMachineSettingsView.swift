import SettingsDomain
import SwiftUI

struct VirtualMachineSettingsView<SettingsStoreType: SettingsStore>: View {
    @StateObject private var viewModel: VirtualMachineSettingsViewModel<SettingsStoreType>
    @ObservedObject private var settingsStore: SettingsStoreType

    init(viewModel: VirtualMachineSettingsViewModel<SettingsStoreType>) {
        self._settingsStore = ObservedObject(wrappedValue: viewModel.settingsStore)
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Form {
            Section {
                VirtualMachinePicker(
                    selection: $settingsStore.virtualMachine,
                    virtualMachineNames: viewModel.virtualMachineNames,
                    isPickerEnabled: viewModel.isSettingsEnabled,
                    isRefreshing: viewModel.isRefreshingVirtualMachines
                ) {
                    Task {
                        await viewModel.refreshVirtualMachines()
                    }
                }
                VirtualMachineCountPicker(selection: $settingsStore.numberOfVirtualMachines)
                    .disabled(!viewModel.isSettingsEnabled)
                Toggle(isOn: $settingsStore.startVirtualMachinesOnLaunch) {
                    Text(L10n.Settings.VirtualMachine.startVirtualMachinesOnAppLaunch)
                }
            }
            Section {
                TextField(
                    L10n.Settings.VirtualMachine.Ssh.username,
                    text: $viewModel.sshUsername,
                    prompt: Text(L10n.Settings.VirtualMachine.Ssh.Username.placeholder)
                )
                .disabled(!viewModel.isSettingsEnabled)
                SecureField(L10n.Settings.VirtualMachine.Ssh.password, text: $viewModel.sshPassword)
                    .disabled(!viewModel.isSettingsEnabled)
            } header: {
                Text(L10n.Settings.VirtualMachine.ssh)
            } footer: {
                Text(L10n.Settings.VirtualMachine.Ssh.footer)
            }
            Section {
                TartHomeFolderPicker(
                    folderURL: $settingsStore.tartHomeFolderURL,
                    isEnabled: viewModel.isSettingsEnabled
                )
            } header: {
                Text(L10n.Settings.VirtualMachine.tartHome)
            } footer: {
                Text(L10n.Settings.VirtualMachine.TartHome.footer)
            }
        }
        .formStyle(.grouped)
        .task {
            await viewModel.refreshVirtualMachines()
        }
        .onChange(of: settingsStore.tartHomeFolderURL) { _ in
            Task {
                await viewModel.refreshVirtualMachines()
            }
        }
    }
}
