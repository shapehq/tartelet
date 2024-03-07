import AppKit
import Foundation
import SettingsUI
import VirtualMachineDomain

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let dock = Dock(
        showAppInDock: Composers.settingsStore
            .onChange
            .map(\.applicationUIMode.showInDock)
            .eraseToAnyPublisher()
    )

    func applicationWillFinishLaunching(_ notification: Notification) {
        dock.setIconShown(Composers.settingsStore.applicationUIMode.showInDock)
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        dock.beginObservingAppIconVisibility()
        if Composers.settingsStore.startVirtualMachinesOnLaunch {
            try? Composers.fleet.start(numberOfMachines: Composers.settingsStore.numberOfVirtualMachines)
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        Composers.editor.stop()
        Composers.fleet.stop()
    }
}
