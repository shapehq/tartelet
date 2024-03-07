import Foundation
import GitHubDomain
import Keychain

public final actor KeychainGitHubCredentialsStore: GitHubCredentialsStore {
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
        get async {
            return await keychain.password(forAccount: PasswordAccount.organizationName, belongingToService: serviceName)
        }
    }
    public var repositoryName: String? {
        get async {
            return await keychain.password(forAccount: PasswordAccount.repositoryName, belongingToService: serviceName)
        }
    }
    public var ownerName: String? {
        get async {
            return await keychain.password(forAccount: PasswordAccount.ownerName, belongingToService: serviceName)
        }
    }
    public var appId: String? {
        get async {
            return await keychain.password(forAccount: PasswordAccount.appId, belongingToService: serviceName)
        }
    }
    public var privateKey: Data? {
        get async {
            return await keychain.key(withTag: KeyTag.privateKey)?.data
        }
    }

    private let keychain: Keychain
    private let serviceName: String

    public init(keychain: Keychain, serviceName: String) {
        self.keychain = keychain
        self.serviceName = serviceName
    }

    public func setOrganizationName(_ organizationName: String?) async {
        if let organizationName {
            _ = await keychain.setPassword(organizationName, forAccount: PasswordAccount.organizationName, belongingToService: serviceName)
        } else {
            await keychain.removePassword(forAccount: PasswordAccount.organizationName, belongingToService: serviceName)
        }
    }
    public func setRepository(_ repositoryName: String?, withOwner ownerName: String?) async {
        if let repositoryName {
            _ = await keychain.setPassword(repositoryName, forAccount: PasswordAccount.repositoryName, belongingToService: serviceName)
        } else {
            await keychain.removePassword(forAccount: PasswordAccount.repositoryName, belongingToService: serviceName)
        }
        if let ownerName {
            _ = await keychain.setPassword(ownerName, forAccount: PasswordAccount.ownerName, belongingToService: serviceName)
        } else {
            await keychain.removePassword(forAccount: PasswordAccount.ownerName, belongingToService: serviceName)
        }
    }

    public func setAppID(_ appID: String?) async {
        if let appID {
            _ = await keychain.setPassword(appID, forAccount: PasswordAccount.appId, belongingToService: serviceName)
        } else {
            await keychain.removePassword(forAccount: PasswordAccount.appId, belongingToService: serviceName)
        }
    }

    public func setPrivateKey(_ privateKeyData: Data?) async {
        if let privateKeyData, let key = RSAPrivateKey(privateKeyData) {
            _ = await keychain.setKey(key, withTag: KeyTag.privateKey)
        } else {
            await keychain.removeKey(withTag: KeyTag.privateKey)
        }
    }
}
