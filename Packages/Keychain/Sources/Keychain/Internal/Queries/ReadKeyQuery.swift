import Foundation

struct ReadKeyQuery: KeychainQuery {
    let accessGroup: String?
    let tag: String

    var rawQuery: CFDictionary {
        var query: [String: Any] = [:]
        query[kSecClass as String] = kSecClassKey
        query[kSecAttrApplicationTag as String] = tag
        query[kSecAttrKeyType as String] = kSecAttrKeyTypeRSA
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnRef as String] = true
        if let accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        return query as CFDictionary
    }
}
