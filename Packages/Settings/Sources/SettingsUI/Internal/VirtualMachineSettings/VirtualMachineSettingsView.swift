import SettingsStore
import SwiftUI

struct VirtualMachineSettingsView: View {
    @StateObject private var viewModel: VirtualMachineSettingsViewModel
    @ObservedObject private var settingsStore: SettingsStore

    init(viewModel: VirtualMachineSettingsViewModel) {
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
