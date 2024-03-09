import Foundation

struct AddKeyQuery: KeychainQuery {
    let accessGroup: String?
    let tag: String
    let key: SecKey

    var rawQuery: CFDictionary {
        var query: [String: Any] = [:]
        query[kSecClass as String] = kSecClassKey
        query[kSecValueRef as String] = key
        query[kSecAttrApplicationTag as String] = tag
        if let accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        return query as CFDictionary
    }
}
