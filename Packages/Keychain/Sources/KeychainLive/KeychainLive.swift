import Foundation
import Keychain
import LocalAuthentication
import RSAPrivateKey

public actor KeychainLive: Keychain {
    private let accessGroup: String?

    public init(accessGroup: String? = nil) {
        self.accessGroup = accessGroup
    }
}

// MARK: - Passwords
public extension KeychainLive {
    func setPassword(_ password: Data, forAccount account: String, belongingToService service: String) async -> Bool {
        let findQuery = FindPasswordQuery(accessGroup: accessGroup, service: service, account: account)
        if SecItemCopyMatching(findQuery.rawQuery, nil) == errSecSuccess {
            let updateQuery = UpdatePasswordQuery(password: password)
            guard SecItemUpdate(findQuery.rawQuery, updateQuery.rawQuery) == errSecSuccess else {
                return false
            }
        } else {
            let addQuery = AddPasswordQuery(accessGroup: accessGroup, service: service, account: account, password: password)
            let status = SecItemAdd(addQuery.rawQuery, nil)
            guard status == errSecSuccess else {
                print(status)
                return false
            }
        }
        return true
    }

    func setPassword(_ password: String, forAccount account: String, belongingToService service: String) async -> Bool {
        guard let data = password.data(using: .utf8) else {
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
            guard SecItemDelete(findQuery.rawQuery) == errSecSuccess else {
                return false
            }
        }
        let addQuery = AddKeyQuery(accessGroup: accessGroup, tag: tag, key: key.rawValue)
        guard SecItemAdd(addQuery.rawQuery, nil) == errSecSuccess else {
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
