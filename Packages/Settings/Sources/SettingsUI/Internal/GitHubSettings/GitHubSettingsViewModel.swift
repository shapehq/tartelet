import AppKit
import Combine
import GitHubDomain
import SettingsDomain
import SwiftUI

@MainActor
final class GitHubSettingsViewModel<SettingsStoreType: SettingsStore>: ObservableObject {
    let settingsStore: SettingsStoreType
    @Published var organizationName: String = ""
    @Published var repositoryName: String = ""
    @Published var ownerName: String = ""
    @Published var appId: String = ""
    @Published var privateKeyName = ""
    @Published var runnerScope: GitHubRunnerScope
    @Published private(set) var isSettingsEnabled = true

    private let credentialsStore: GitHubCredentialsStore
    private var cancellables: Set<AnyCancellable> = []
    private var createAppURL: URL {
        var url = URL(string: "https://github.com")!
        if !organizationName.isEmpty, case .organization = runnerScope {
            url = url.appending(path: "/organizations/\(organizationName)")
        }
        return url.appending(path: "/settings/apps")
    }

    init(
        settingsStore: SettingsStoreType,
        credentialsStore: GitHubCredentialsStore,
        isSettingsEnabled: AnyPublisher<Bool, Never>
    ) {
        self.settingsStore = settingsStore
        self.credentialsStore = credentialsStore
        self.runnerScope = settingsStore.githubRunnerScope
        organizationName = credentialsStore.organizationName ?? ""
        repositoryName = credentialsStore.repositoryName ?? ""
        ownerName = credentialsStore.ownerName ?? ""
        appId = credentialsStore.appId ?? ""
        let privateKey = credentialsStore.privateKey
        privateKeyName = privateKey != nil ? settingsStore.gitHubPrivateKeyName ?? "" : ""
        isSettingsEnabled.assign(to: \.isSettingsEnabled, on: self).store(in: &cancellables)
        $appId
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .nilIfEmpty()
            .dropFirst()
            .sink { [weak self] appId in
                Task {
                    self?.credentialsStore.setAppID(appId)
                }
            }.store(in: &cancellables)
        $runnerScope
            .combineLatest(
                $organizationName.nilIfEmpty(),
                $ownerName.nilIfEmpty(),
                $repositoryName.nilIfEmpty()
            )
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .dropFirst()
            .sink { [weak self] runnerScope, organizationName, ownerName, repositoryName in
                self?.settingsStore.githubRunnerScope = runnerScope
                switch runnerScope {
                case .organization:
                    Task {
                        self?.credentialsStore.setOrganizationName(organizationName)
                        self?.credentialsStore.setRepository(nil, withOwner: nil)
                    }
                case .repo:
                    Task {
                        self?.credentialsStore.setOrganizationName(nil)
                        self?.credentialsStore.setRepository(repositoryName, withOwner: ownerName)
                    }
                }
            }.store(in: &cancellables)
    }

    func openCreateApp() {
        NSWorkspace.shared.open(createAppURL)
    }

    func storePrivateKey(at fileURL: URL) async {
        do {
            let data = try Data(contentsOf: fileURL)
            credentialsStore.setPrivateKey(data)
            let didStorePrivateKey = credentialsStore.privateKey != nil
            settingsStore.gitHubPrivateKeyName = didStorePrivateKey ? fileURL.lastPathComponent : nil
            privateKeyName = settingsStore.gitHubPrivateKeyName ?? ""
        } catch {
            #if DEBUG
            print(error)
            #endif
        }
    }
}

private extension Publisher where Output == String {
    func nilIfEmpty() -> AnyPublisher<String?, Failure> {
        map { !$0.isEmpty ? $0 : nil }.eraseToAnyPublisher()
    }
}
