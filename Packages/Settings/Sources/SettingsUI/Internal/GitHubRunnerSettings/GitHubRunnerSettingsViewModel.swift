import Combine
import SettingsStore
import SwiftUI

@MainActor
final class GitHubRunnerSettingsViewModel: ObservableObject {
    let settingsStore: SettingsStore
    @Published var labels: String = ""
    @Published var group: String = ""
    @Published private(set) var isSettingsEnabled = true

    private var cancellables: Set<AnyCancellable> = []

    init(settingsStore: SettingsStore, isSettingsEnabled: AnyPublisher<Bool, Never>) {
        self.settingsStore = settingsStore
        labels = settingsStore.gitHubRunnerLabels
        isSettingsEnabled.assign(to: \.isSettingsEnabled, on: self).store(in: &cancellables)
        $labels.debounce(for: 0.5, scheduler: DispatchQueue.main).dropFirst().sink { [weak self] labels in
            self?.settingsStore.gitHubRunnerLabels = labels
        }.store(in: &cancellables)
        $group.debounce(for: 0.5, scheduler: DispatchQueue.main).dropFirst().sink { [weak self] group in
            self?.settingsStore.gitHubRunnerGroup = group
        }.store(in: &cancellables)
    }
}
