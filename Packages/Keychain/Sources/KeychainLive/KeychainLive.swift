import Foundation
import Keychain
import LocalAuthentication
import LogConsumer
import RSAPrivateKey

public actor KeychainLive: Keychain {
    private let logger: LogConsumer
    private let accessGroup: String?

    public init(logger: LogConsumer, accessGroup: String? = nil) {
        self.logger = logger
        self.accessGroup = accessGroup
    }
}

// MARK: - Passwords
public extension KeychainLive {
    func setPassword(_ password: Data, forAccount account: String, belongingToService service: String) async -> Bool {
        let findQuery = FindPasswordQuery(accessGroup: accessGroup, service: service, account: account)
        if SecItemCopyMatching(findQuery.rawQuery, nil) == errSecSuccess {
            let updateQuery = UpdatePasswordQuery(password: password)
            let updateStatus = SecItemUpdate(findQuery.rawQuery, updateQuery.rawQuery)
            guard updateStatus == errSecSuccess else {
                logger.error(
                    "Failed updating password for account \"%@\" belong to service \"%@\". Received status: %d",
                    account,
                    service,
                    updateStatus
                )
                return false
            }
        } else {
            let addQuery = AddPasswordQuery(accessGroup: accessGroup, service: service, account: account, password: password)
            let addStatus = SecItemAdd(addQuery.rawQuery, nil)
            guard addStatus == errSecSuccess else {
                logger.error(
                    "Failed setting password for account \"%@\" belong to service \"%@\". Received status: %d",
                    account,
                    service,
                    addStatus
                )
                return false
            }
        }
        return true
    }

    func setPassword(_ password: String, forAccount account: String, belongingToService service: String) async -> Bool {
        guard let data = password.data(using: .utf8) else {
            logger.error(
                "Failed setting password for account \"%@\" belong to service \"%@\" because the password could not be converted to UTF-8 data",
                account,
                service
            )
            return false
        }
        return await setPassword(data, forAccount: account, belongingToService: service)
    }

    func password(forAccount account: String, belongingToService service: String) async -> Data? {
        let query = ReadPasswordQuery(accessGroup: accessGroup, service: service, account: account)
        return read(Data.self, usingQuery: query.rawQuery)
    }

    func password(forAccount account: String, belongingToService service: String) async -> String? {
        let query = ReadPasswordQuery(accessGroup: accessGroup, service: service, account: account)
        guard let data = read(Data.self, usingQuery: query.rawQuery) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    func removePassword(forAccount account: String, belongingToService service: String) async {
        let query = FindPasswordQuery(accessGroup: accessGroup, service: service, account: account)
        SecItemDelete(query.rawQuery)
    }
}

// MARK: - Keys
public extension KeychainLive {
    func setKey(_ key: RSAPrivateKey, withTag tag: String) async -> Bool {
        let findQuery = FindKeyQuery(accessGroup: accessGroup, tag: tag)
        if SecItemCopyMatching(findQuery.rawQuery, nil) == errSecSuccess {
            let removeStatus = SecItemDelete(findQuery.rawQuery)
            guard removeStatus == errSecSuccess else {
                logger.error("Failed removing existing RSA private key with tag \"%@\". Received status code: %d", tag, removeStatus)
                return false
            }
        }
        let addQuery = AddKeyQuery(accessGroup: accessGroup, tag: tag, key: key.rawValue)
        let addStatus = SecItemAdd(addQuery.rawQuery, nil)
        guard addStatus == errSecSuccess else {
            logger.error("Failed storing RSA private key with tag \"%@\". Received status code: %d", tag, addStatus)
            return false
        }
        return true
    }

    func key(withTag tag: String) async -> RSAPrivateKey? {
        let query = ReadKeyQuery(accessGroup: accessGroup, tag: tag)
        guard let key = read(SecKey.self, usingQuery: query.rawQuery) else {
            return nil
        }
        return RSAPrivateKey(key)
    }

    func removeKey(withTag tag: String) async {
        let query = FindKeyQuery(accessGroup: accessGroup, tag: tag)
        SecItemDelete(query.rawQuery)
    }
}

// MARK: - Helpers
private extension KeychainLive {
    private func read<T>(_ valueType: T.Type, usingQuery query: CFDictionary) -> T? {
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query, &item)
        guard let value = item as? T, status == errSecSuccess else {
            return nil
        }
        return value
    }
}
