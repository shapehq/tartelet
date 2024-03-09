import Observation
import SettingsDomain
import SwiftUI
import VirtualMachineDomain

struct VirtualMachineSettingsView<SettingsStoreType: SettingsStore & Observable>: View {
    @Bindable var settingsStore: SettingsStoreType
    let credentialsStore: VirtualMachineSSHCredentialsStore
    let virtualMachinesSourceNameRepository: VirtualMachineSourceNameRepository
    let isSettingsEnabled: Bool

    @State private var virtualMachineNames: [String] = []
    @State private var isRefreshingVirtualMachines = false
    @State private var sshUsername = ""
    @State private var sshPassword = ""

    var body: some View {
        Form {
            Section {
                VirtualMachinePicker(
                    selection: $settingsStore.virtualMachine,
                    virtualMachineNames: virtualMachineNames,
                    isPickerEnabled: isSettingsEnabled,
                    isRefreshing: isRefreshingVirtualMachines
                ) {
                    Task {
                        await refreshVirtualMachines()
                    }
                }
                VirtualMachineCountPicker(selection: $settingsStore.numberOfVirtualMachines)
                    .disabled(!isSettingsEnabled)
                Toggle(isOn: $settingsStore.startVirtualMachinesOnLaunch) {
                    Text(L10n.Settings.VirtualMachine.startVirtualMachinesOnAppLaunch)
                }
            }
            Section {
                TextField(
                    L10n.Settings.VirtualMachine.Ssh.username,
                    text: $sshUsername,
                    prompt: Text(L10n.Settings.VirtualMachine.Ssh.Username.placeholder)
                )
                .disabled(!isSettingsEnabled)
                SecureField(L10n.Settings.VirtualMachine.Ssh.password, text: $sshPassword)
                    .disabled(!isSettingsEnabled)
            } header: {
                Text(L10n.Settings.VirtualMachine.ssh)
            } footer: {
                Text(L10n.Settings.VirtualMachine.Ssh.footer)
            }
            Section {
                TartHomeFolderPicker(
                    folderURL: $settingsStore.tartHomeFolderURL,
                    isEnabled: isSettingsEnabled
                )
            } header: {
                Text(L10n.Settings.VirtualMachine.tartHome)
            } footer: {
                Text(L10n.Settings.VirtualMachine.TartHome.footer)
            }
        }
        .formStyle(.grouped)
        .task {
            await refreshVirtualMachines()
        }
        .onAppear {
            sshUsername = credentialsStore.username ?? ""
            sshPassword = credentialsStore.password ?? ""
        }
        .onChange(of: settingsStore.tartHomeFolderURL) { _, _ in
            Task {
                await refreshVirtualMachines()
            }
        }
        .onChange(of: sshUsername) { _, newValue in
            if !newValue.isEmpty {
                credentialsStore.setUsername(newValue)
            } else {
                credentialsStore.setUsername(nil)
            }
        }
        .onChange(of: sshPassword) { _, newValue in
            if !newValue.isEmpty {
                credentialsStore.setPassword(newValue)
            } else {
                credentialsStore.setPassword(nil)
            }
        }
    }
}

private extension VirtualMachineSettingsView {
    @MainActor
    func refreshVirtualMachines() async {
        isRefreshingVirtualMachines = true
        defer {
            isRefreshingVirtualMachines = false
        }
        do {
            virtualMachineNames = try await self.virtualMachinesSourceNameRepository.sourceNames()
            if case let .virtualMachine(name) = settingsStore.virtualMachine, !virtualMachineNames.contains(name) {
                settingsStore.virtualMachine = .unknown
            }
        } catch {
            #if DEBUG
            print(error)
            #endif
        }
    }
}
