import AppKit
import Combine
import GitHubCredentialsStore
import GitHubService
import SettingsStore
import SwiftUI

@MainActor
final class GitHubSettingsViewModel: ObservableObject {
    let settingsStore: SettingsStore
    @Published var organizationName: String = ""
    @Published var repositoryName: String = ""
    @Published var ownerName: String = ""
    @Published var appId: String = ""
    @Published var privateKeyName = ""
    @Published var version: GitHubServiceVersion.Kind
    @Published var selfHostedRaw: String = ""
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

    init(settingsStore: SettingsStore, credentialsStore: GitHubCredentialsStore, isSettingsEnabled: AnyPublisher<Bool, Never>) {
        self.settingsStore = settingsStore
        self.credentialsStore = credentialsStore
        self.version = settingsStore.githubServiceVersion
        self.runnerScope = settingsStore.githubRunnerScope
        isSettingsEnabled.assign(to: \.isSettingsEnabled, on: self).store(in: &cancellables)
        $appId.debounce(for: 0.5, scheduler: DispatchQueue.main).nilIfEmpty().dropFirst().sink { [weak self] appId in
            Task {
                await self?.credentialsStore.setAppID(appId)
            }
        }.store(in: &cancellables)

        $version
            .combineLatest($selfHostedRaw)
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .dropFirst()
            .sink { [weak self] version, value in
                self?.settingsStore.githubServiceVersion = version
                switch version {
                case .dotCom:
                    Task {
                        await self?.credentialsStore.setSelfHostedURL(nil)
                    }
                case .enterprise:
                    Task {
                        await self?.credentialsStore.setSelfHostedURL(URL(string: value))
                    }
                }
            }
            .store(in: &cancellables)

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
                        await self?.credentialsStore.setOrganizationName(organizationName)
                        await self?.credentialsStore.setRepository(nil, withOwner: nil)
                    }
                case .repo:
                    Task {
                        await self?.credentialsStore.setOrganizationName(nil)
                        await self?.credentialsStore.setRepository(repositoryName, withOwner: ownerName)
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
            await credentialsStore.setPrivateKey(data)
            let didStorePrivateKey = await credentialsStore.privateKey != nil
            settingsStore.gitHubPrivateKeyName = didStorePrivateKey ? fileURL.lastPathComponent : nil
            privateKeyName = settingsStore.gitHubPrivateKeyName ?? ""
        } catch {
            #if DEBUG
            print(error)
            #endif
        }
    }

    func loadCredentials() async {
        if let selfHostedURL = await credentialsStore.selfHostedURL {
            selfHostedRaw = selfHostedURL.absoluteString
            version = .enterprise
        } else {
            selfHostedRaw = ""
            version = .dotCom
        }
        organizationName = await credentialsStore.organizationName ?? ""
        repositoryName = await credentialsStore.repositoryName ?? ""
        ownerName = await credentialsStore.ownerName ?? ""
        appId = await credentialsStore.appId ?? ""
        let privateKey = await credentialsStore.privateKey
        privateKeyName = privateKey != nil ? settingsStore.gitHubPrivateKeyName ?? "" : ""
    }
}

private extension Publisher where Output == String {
    func nilIfEmpty() -> AnyPublisher<String?, Failure> {
        map { !$0.isEmpty ? $0 : nil }.eraseToAnyPublisher()
    }
}
