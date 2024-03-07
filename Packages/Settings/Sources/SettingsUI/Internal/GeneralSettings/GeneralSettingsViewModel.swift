import LoggingDomain
import SettingsDomain
import SwiftUI

@MainActor
final class GeneralSettingsViewModel<SettingsStoreType: SettingsStore>: ObservableObject {
    let settingsStore: SettingsStoreType
    @Published private(set) var isExportingLogs = false

    private let logExporter: LogExporter

    init(settingsStore: SettingsStoreType, logExporter: LogExporter) {
        self.settingsStore = settingsStore
        self.logExporter = logExporter
    }

    func exportLogs() async {
        isExportingLogs = true
        defer {
            isExportingLogs = false
        }
        do {
            let fileURL = try await logExporter.export()
            NSWorkspace.shared.activateFileViewerSelecting([fileURL])
        } catch {
            #if DEBUG
            print(error)
            #endif
        }
    }
}
