import AppKit
import Foundation
import SettingsUI
import VirtualMachineDomain

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let settingsStore = Composers.settingsStore
    private let dock = Dock()

    func applicationWillFinishLaunching(_ notification: Notification) {
        dock.setIconShown(Composers.settingsStore.applicationUIMode.showInDock)
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        beginObservingAppIconVisibility()
        if Composers.settingsStore.startVirtualMachinesOnLaunch {
            try? Composers.fleet.start(numberOfMachines: Composers.settingsStore.numberOfVirtualMachines)
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        Composers.editor.stop()
        Composers.fleet.stop()
    }
}

private extension AppDelegate {
    private func beginObservingAppIconVisibility() {
        withObservationTracking {
            _ = settingsStore.applicationUIMode
        } onChange: {
            DispatchQueue.main.async {
                self.dock.setIconShown(self.settingsStore.applicationUIMode.showInDock)
                self.beginObservingAppIconVisibility()
            }
        }
    }
}
