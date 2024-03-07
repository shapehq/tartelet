import LoggingDomain
import SettingsDomain
import SwiftUI

struct GeneralSettingsView<SettingsStoreType: SettingsStore>: View {
    @StateObject private var viewModel: GeneralSettingsViewModel<SettingsStoreType>
    @ObservedObject private var settingsStore: SettingsStoreType

    init(viewModel: GeneralSettingsViewModel<SettingsStoreType>) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _settingsStore = ObservedObject(wrappedValue: viewModel.settingsStore)
    }

    var body: some View {
        Form {
            Picker(
                L10n.Settings.General.applicationUiMode,
                selection: $settingsStore.applicationUIMode
            ) {
                ForEach(ApplicationUIMode.allCases) { mode in
                    Text(mode.title)
                }
            }
        }
        .formStyle(.grouped)
        .overlay(alignment: .bottomTrailing) {
            HStack {
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(x: 0.5, y: 0.5)
                    .opacity(viewModel.isExportingLogs ? 1 : 0)
                Button(L10n.Settings.General.exportLogs) {
                    Task.detached {
                        await viewModel.exportLogs()
                    }
                }.disabled(viewModel.isExportingLogs)
            }
        }
        .padding()
    }
}
