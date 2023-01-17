import SwiftUI

@main
struct TarteletApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        CompositionRoot.menuBarItem
        CompositionRoot.settingsWindow
    }
}
