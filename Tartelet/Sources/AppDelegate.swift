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
            Composers.fleet.start(numberOfMachines: Composers.settingsStore.numberOfVirtualMachines)
        }

        // If Tartelet is launched as a login item, we can keep the window hidden
        if launchedAsLogInItem == false {
            openSettingsWindow()
        }
    }

    // This delegate method let's you perform an action whenever the Finder reactivates an already
    // running application when the app is double-clicked again or clicked on in the dock.
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        openSettingsWindow()
        return true
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

    private var launchedAsLogInItem: Bool {
        // source: https://stackoverflow.com/a/19890943/4118208
        guard let event = NSAppleEventManager.shared().currentAppleEvent else {
            return false
        }
        return
            event.eventID == kAEOpenApplication &&
            event.paramDescriptor(forKeyword: keyAEPropData)?.enumCodeValue == keyAELaunchedAsLogInItem
    }

    /// Opens Tartelet's Settings window
    ///
    /// To open the Settings/Preferences window programmatically in the past, we'd use:
    ///
    /// ```swift
    /// NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
    /// ```
    ///
    /// Unfortunately, Apple removed the ability to do that, so we have to do the slightly
    /// hacky alternative of scanning through the app's menu items and activating the
    /// "Settings…" menu item directly. Not ideal, but it works.
    func openSettingsWindow() {
        // Works around an annoyance where the app always comes to the foreground when
        // being previewed in Xcode's SwiftUI Canvas.
        guard
            ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1"
        else {
            return
        }

        guard
            let menu = NSApplication.shared.menu,
            let sensoriumMenu = menu.items.first,
            let sensoriumMenuSubmenu = sensoriumMenu.submenu,
            let settingsMenuItem = sensoriumMenuSubmenu.items[safe: 2],
            let settingsMenuItemAction = settingsMenuItem.action
        else {
            return
        }

        NSApp.sendAction(
            settingsMenuItemAction,
            to: settingsMenuItem.target,
            from: settingsMenuItem
        )
        NSApp.activate(ignoringOtherApps: true)
    }
}

extension Collection {
    /// Checks first if an index exists in an array, and returns `nil` if it does not exist.
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
