import Combine
import SettingsStore

final class ShowAppInDockPublisher {
    let rawValue: AnyPublisher<Bool, Never>

    init(settingsStore: SettingsStore) {
        self.rawValue = settingsStore.onChange.map(\.applicationUIMode.showInDock).eraseToAnyPublisher()
    }
}
