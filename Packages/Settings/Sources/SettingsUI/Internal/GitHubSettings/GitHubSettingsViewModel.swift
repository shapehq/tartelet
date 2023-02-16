import AppKit
import Combine
import GitHubCredentialsStore
import SettingsStore
import SwiftUI

@MainActor
final class GitHubSettingsViewModel: ObservableObject {
    let settingsStore: SettingsStore
    @Published var organizationName: String = ""
    @Published var appId: String = ""
    @Published private(set) var privateKeyName: String?
    @Published private(set) var isSettingsEnabled = true

    private let credentialsStore: GitHubCredentialsStore
    private var cancellables: Set<AnyCancellable> = []
    private var createAppURL: URL {
        var url = URL(string: "https://github.com")!
        if !organizationName.isEmpty {
            url = url.appending(path: "/organizations/\(organizationName)")
        }
        return url.appending(path: "/settings/apps")
    }

    init(settingsStore: SettingsStore, credentialsStore: GitHubCredentialsStore, isSettingsEnabled: AnyPublisher<Bool, Never>) {
        self.settingsStore = settingsStore
        self.credentialsStore = credentialsStore
        isSettingsEnabled.assign(to: \.isSettingsEnabled, on: self).store(in: &cancellables)
        $organizationName.debounce(for: 0.5, scheduler: DispatchQueue.main).nilIfEmpty().dropFirst().sink { [weak self] organizationName in
            Task {
                await self?.credentialsStore.setOrganizationName(organizationName)
            }
        }.store(in: &cancellables)
        $appId.debounce(for: 0.5, scheduler: DispatchQueue.main).nilIfEmpty().dropFirst().sink { [weak self] appId in
            Task {
                await self?.credentialsStore.setAppID(appId)
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
            privateKeyName = settingsStore.gitHubPrivateKeyName
        } catch {
            #if DEBUG
            print(error)
            #endif
        }
    }

    func loadCredentials() async {
        organizationName = await credentialsStore.organizationName ?? ""
        appId = await credentialsStore.appId ?? ""
        let privateKey = await credentialsStore.privateKey
        privateKeyName = privateKey != nil ? settingsStore.gitHubPrivateKeyName : nil
    }
}

private extension Publisher where Output == String {
    func nilIfEmpty() -> AnyPublisher<String?, Failure> {
        map { !$0.isEmpty ? $0 : nil }.eraseToAnyPublisher()
    }
}
