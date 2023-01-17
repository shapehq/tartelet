import Settings
import SettingsStore
import SwiftUI

struct GeneralSettingsView: View {
    @StateObject private var settingsStore: SettingsStore

    init(settingsStore: SettingsStore) {
        _settingsStore = StateObject(wrappedValue: settingsStore)
    }

    var body: some View {
        Form {
            Picker(L10n.Settings.General.applicationUiMode, selection: $settingsStore.applicationUIMode) {
                ForEach(ApplicationUIMode.allCases) { mode in
                    Text(mode.title)
                }
            }
        }.padding()
    }
}
