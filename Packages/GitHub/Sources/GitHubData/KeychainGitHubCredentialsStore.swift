import Foundation
import GitHubDomain
import Keychain

@Observable
public final class KeychainGitHubCredentialsStore: GitHubCredentialsStore {
    private enum PasswordAccount {
        static let organizationName = "github.credentials.organizationName"
        static let repositoryName = "github.credentials.repositoryName"
        static let ownerName = "github.credentials.ownerName"
        static let appId = "github.credentials.appId"
    }

    private enum KeyTag {
        static let privateKey = "github.credentials.privateKey"
    }

    public var organizationName: String? {
        access(keyPath: \.organizationName)
        return keychain.password(
            forAccount: PasswordAccount.organizationName,
            belongingToService: serviceName
        )
    }
    public var repositoryName: String? {
        access(keyPath: \.repositoryName)
        return keychain.password(
            forAccount: PasswordAccount.repositoryName,
            belongingToService: serviceName
        )
    }
    public var ownerName: String? {
        access(keyPath: \.ownerName)
        return keychain.password(
            forAccount: PasswordAccount.ownerName,
            belongingToService: serviceName
        )
    }
    public var appId: String? {
        access(keyPath: \.appId)
        return keychain.password(
            forAccount: PasswordAccount.appId,
            belongingToService: serviceName
        )
    }
    public var privateKey: Data? {
        access(keyPath: \.privateKey)
        return keychain.key(withTag: KeyTag.privateKey)?.data
    }

    private let keychain: Keychain
    private let serviceName: String

    public init(keychain: Keychain, serviceName: String) {
        self.keychain = keychain
        self.serviceName = serviceName
    }

    public func setOrganizationName(_ organizationName: String?) {
        withMutation(keyPath: \.organizationName) {
            if let organizationName {
                _ = keychain.setPassword(
                    organizationName,
                    forAccount: PasswordAccount.organizationName,
                    belongingToService: serviceName
                )
            } else {
                keychain.removePassword(
                    forAccount: PasswordAccount.organizationName,
                    belongingToService: serviceName
                )
            }
        }
    }

    public func setRepository(_ repositoryName: String?, withOwner ownerName: String?) {
        withMutation(keyPath: \.repositoryName) {
            if let repositoryName {
                _ = keychain.setPassword(
                    repositoryName,
                    forAccount: PasswordAccount.repositoryName,
                    belongingToService: serviceName
                )
            } else {
                keychain.removePassword(
                    forAccount: PasswordAccount.repositoryName,
                    belongingToService: serviceName
                )
            }
        }
        withMutation(keyPath: \.ownerName) {
            if let ownerName {
                _ = keychain.setPassword(
                    ownerName,
                    forAccount: PasswordAccount.ownerName,
                    belongingToService: serviceName
                )
            } else {
                keychain.removePassword(
                    forAccount: PasswordAccount.ownerName,
                    belongingToService: serviceName
                )
            }
        }
    }

    public func setAppID(_ appID: String?) {
        withMutation(keyPath: \.appId) {
            if let appID {
                _ = keychain.setPassword(
                    appID,
                    forAccount: PasswordAccount.appId,
                    belongingToService: serviceName
                )
            } else {
                keychain.removePassword(
                    forAccount: PasswordAccount.appId,
                    belongingToService: serviceName
                )
            }
        }
    }

    public func setPrivateKey(_ privateKeyData: Data?) {
        withMutation(keyPath: \.privateKey) {
            if let privateKeyData, let key = RSAPrivateKey(privateKeyData) {
                _ = keychain.setKey(key, withTag: KeyTag.privateKey)
            } else {
                keychain.removeKey(withTag: KeyTag.privateKey)
            }
        }
    }
}
