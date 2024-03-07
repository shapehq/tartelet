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
                TartHomeFolderPicker(
                    folderURL: $settingsStore.tartHomeFolderURL,
                    isEnabled: viewModel.isSettingsEnabled
                )
            } footer: {
                Text(L10n.Settings.VirtualMachine.TartHomeFolder.footer)
                    .foregroundColor(.secondary)
            }
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
            }
            Section {
                Toggle(isOn: $settingsStore.startVirtualMachinesOnLaunch) {
                    Text(L10n.Settings.VirtualMachine.startVirtualMachinesOnAppLaunch)
                }
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
