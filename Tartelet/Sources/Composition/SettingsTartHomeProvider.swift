import Foundation
import SettingsStore
import Tart

struct SettingsTartHomeProvider: TartHomeProvider {
    var homeFolderURL: URL? {
        settingsStore.tartHomeFolderURL
    }

    let settingsStore: SettingsStore
}
