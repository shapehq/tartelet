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
            VirtualMachinePicker(
                selection: $settingsStore.virtualMachine,
                virtualMachineNames: viewModel.virtualMachineNames,
                isPickerEnabled: viewModel.isVirtualMachineSettingsEnabled,
                isRefreshing: viewModel.isRefreshingVirtualMachines
            ) {
                Task {
                    await viewModel.refreshVirtualMachines()
                }
            }
            VirtualMachineCountPicker(selection: $settingsStore.numberOfVirtualMachines)
                .disabled(!viewModel.isVirtualMachineSettingsEnabled)
        }
        .padding()
        .task {
            await viewModel.refreshVirtualMachines()
        }
    }
}
