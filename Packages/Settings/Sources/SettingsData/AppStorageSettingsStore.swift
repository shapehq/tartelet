import GitHubDomain
import SettingsDomain
import SwiftUI

@Observable
public final class AppStorageSettingsStore: SettingsStore {
    private enum AppStorageKey {
        static let applicationUIMode = "applicationUIMode"
        static let tartHomeFolderURL = "tartHomeFolderURL"
        static let virtualMachine = "virtualMachine"
        static let numberOfVirtualMachines = "numberOfVirtualMachines"
        static let startVirtualMachinesOnLaunch = "startVirtualMachinesOnLaunch"
        static let gitHubPrivateKeyName = "gitHubPrivateKeyName"
        static let gitHubRunnerLabels = "gitHubRunnerLabels"
        static let gitHubRunnerGroup = "gitHubRunnerGroup"
        static let githubRunnerScope = "githubRunnerScope"
    }

    public var applicationUIMode: ApplicationUIMode {
        get {
            access(keyPath: \.applicationUIMode)
            return userDefaults.getRawRepresentable(
                ApplicationUIMode.self,
                forKey: AppStorageKey.applicationUIMode
            ) ?? .dockAndMenuBar
        }
        set {
            withMutation(keyPath: \.applicationUIMode) {
                userDefaults.setRawRepresentable(newValue, forKey: AppStorageKey.applicationUIMode)
            }
        }
    }
    public var tartHomeFolderURL: URL? {
        get {
            access(keyPath: \.tartHomeFolderURL)
            return userDefaults.url(forKey: AppStorageKey.tartHomeFolderURL)
        }
        set {
            withMutation(keyPath: \.tartHomeFolderURL) {
                userDefaults.set(newValue, forKey: AppStorageKey.tartHomeFolderURL)
            }
        }
    }
    public var virtualMachine: VirtualMachine {
        get {
            access(keyPath: \.virtualMachine)
            return userDefaults.getRawRepresentable(
                VirtualMachine.self,
                forKey: AppStorageKey.virtualMachine
            ) ?? .unknown
        }
        set {
            withMutation(keyPath: \.virtualMachine) {
                userDefaults.setRawRepresentable(newValue, forKey: AppStorageKey.virtualMachine)
            }
        }
    }
    public var numberOfVirtualMachines: Int {
        get {
            access(keyPath: \.numberOfVirtualMachines)
            guard let value = userDefaults.object(forKey: AppStorageKey.numberOfVirtualMachines) as? Int else {
                return 1
            }
            return value
        }
        set {
            withMutation(keyPath: \.numberOfVirtualMachines) {
                userDefaults.setValue(newValue, forKey: AppStorageKey.numberOfVirtualMachines)
            }
        }
    }
    public var startVirtualMachinesOnLaunch: Bool {
        get {
            access(keyPath: \.startVirtualMachinesOnLaunch)
            return userDefaults.bool(forKey: AppStorageKey.startVirtualMachinesOnLaunch)
        }
        set {
            withMutation(keyPath: \.startVirtualMachinesOnLaunch) {
                userDefaults.setValue(newValue, forKey: AppStorageKey.startVirtualMachinesOnLaunch)
            }
        }
    }
    public var gitHubPrivateKeyName: String? {
        get {
            access(keyPath: \.gitHubPrivateKeyName)
            return userDefaults.string(forKey: AppStorageKey.gitHubPrivateKeyName)
        }
        set {
            withMutation(keyPath: \.gitHubPrivateKeyName) {
                userDefaults.setValue(newValue, forKey: AppStorageKey.gitHubPrivateKeyName)
            }
        }
    }
    public var gitHubRunnerLabels: String {
        get {
            access(keyPath: \.gitHubRunnerLabels)
            return userDefaults.string(forKey: AppStorageKey.gitHubRunnerLabels) ?? "tartelet"
        }
        set {
            withMutation(keyPath: \.gitHubRunnerLabels) {
                userDefaults.setValue(newValue, forKey: AppStorageKey.gitHubRunnerLabels)
            }
        }
    }
    public var gitHubRunnerGroup: String {
        get {
            access(keyPath: \.gitHubRunnerGroup)
            return userDefaults.string(forKey: AppStorageKey.gitHubRunnerGroup) ?? ""
        }
        set {
            withMutation(keyPath: \.gitHubRunnerGroup) {
                userDefaults.setValue(newValue, forKey: AppStorageKey.gitHubRunnerGroup)
            }
        }
    }
    public var githubRunnerScope: GitHubRunnerScope {
        get {
            access(keyPath: \.githubRunnerScope)
            return userDefaults.getRawRepresentable(
                GitHubRunnerScope.self,
                forKey: AppStorageKey.githubRunnerScope
            ) ?? .organization
        }
        set {
            withMutation(keyPath: \.githubRunnerScope) {
                userDefaults.setRawRepresentable(newValue, forKey: AppStorageKey.githubRunnerScope)
            }
        }
    }

    private let userDefaults: UserDefaults

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
}

private extension UserDefaults {
    func getRawRepresentable<T: RawRepresentable>(
        _ type: T.Type,
        forKey key: String
    ) -> T? where T.RawValue == String {
        guard let rawValue = string(forKey: key) else {
            return nil
        }
        return T(rawValue: rawValue)
    }

    func setRawRepresentable<T: RawRepresentable>(
        _ value: T,
        forKey key: String
    ) where T.RawValue == String {
        setValue(value.rawValue, forKey: key)
    }
}
