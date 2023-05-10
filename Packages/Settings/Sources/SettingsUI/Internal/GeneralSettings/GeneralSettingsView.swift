import LogExporter
import Settings
import SettingsStore
import SwiftUI

struct GeneralSettingsView: View {
    @StateObject private var viewModel: GeneralSettingsViewModel
    @ObservedObject private var settingsStore: SettingsStore

    init(viewModel: GeneralSettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _settingsStore = ObservedObject(wrappedValue: viewModel.settingsStore)
    }

    var body: some View {
        Form {
            Spacer()
            Picker(L10n.Settings.General.applicationUiMode, selection: $settingsStore.applicationUIMode) {
                ForEach(ApplicationUIMode.allCases) { mode in
                    Text(mode.title)
                }
            }
            Spacer()
        }
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
