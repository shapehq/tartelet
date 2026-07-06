import Foundation
import SettingsDomain
import VirtualMachineData

public struct SettingsTartHomeProvider<SettingsStoreType: SettingsStore>: TartHomeProvider {
    public let settingsStore: SettingsStoreType
    public var homeFolderURL: URL? {
        settingsStore.tartHomeFolderURL
    }

    public init(settingsStore: SettingsStoreType) {
        self.settingsStore = settingsStore
    }
}
