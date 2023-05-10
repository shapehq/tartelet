import LogExporter
import SettingsStore
import SwiftUI

@MainActor
final class GeneralSettingsViewModel: ObservableObject {
    let settingsStore: SettingsStore
    @Published private(set) var isExportingLogs = false

    private let logExporter: LogExporter

    init(settingsStore: SettingsStore, logExporter: LogExporter) {
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
