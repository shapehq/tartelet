import SettingsDomain
import VirtualMachineDomain

struct SettingsVirtualMachineSSHCredentials<SettingsStoreType: SettingsStore>: VirtualMachineSSHCredentials {
    let settingsStore: SettingsStoreType
    var username: String {
        "runner"
    }
    var password: String {
        "runner"
    }
}
