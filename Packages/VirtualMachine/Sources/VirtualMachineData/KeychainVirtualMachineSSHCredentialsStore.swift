import Foundation
import Keychain
import VirtualMachineDomain

@Observable
public final class KeychainVirtualMachineSSHCredentialsStore: VirtualMachineSSHCredentialsStore {
    private enum PasswordAccount {
        static let username = "virtual_machine.ssh.username"
        static let password = "virtual_machine.ssh.password"
    }

    public var username: String? {
        access(keyPath: \.username)
        return keychain.password(forAccount: PasswordAccount.username, belongingToService: serviceName)
    }

    public var password: String? {
        access(keyPath: \.password)
        return keychain.password(forAccount: PasswordAccount.password, belongingToService: serviceName)
    }

    private let keychain: Keychain
    private let serviceName: String

    public init(keychain: Keychain, serviceName: String) {
        self.keychain = keychain
        self.serviceName = serviceName
    }

    public func setUsername(_ username: String?) {
        withMutation(keyPath: \.username) {
            if let username {
                _ = keychain.setPassword(
                    username,
                    forAccount: PasswordAccount.username,
                    belongingToService: serviceName
                )
            } else {
                keychain.removePassword(
                    forAccount: PasswordAccount.username,
                    belongingToService: serviceName
                )
            }
        }
    }

    public func setPassword(_ password: String?) {
        withMutation(keyPath: \.password) {
            if let password {
                _ = keychain.setPassword(
                    password,
                    forAccount: PasswordAccount.password,
                    belongingToService: serviceName
                )
            } else {
                keychain.removePassword(
                    forAccount: PasswordAccount.password,
                    belongingToService: serviceName
                )
            }
        }
    }
}
