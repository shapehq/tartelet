import Foundation
import SettingsDomain
import VirtualMachineData

struct SettingsTartHomeProvider<SettingsStoreType: SettingsStore>: TartHomeProvider {
    let settingsStore: SettingsStoreType
    var homeFolderURL: URL? {
        settingsStore.tartHomeFolderURL
    }
}
