import Foundation

struct UpdatePasswordQuery: KeychainQuery {
    let password: Data

    var rawQuery: CFDictionary {
        var query: [String: Any] = [:]
        query[kSecValueData as String] = password
        query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        return query as CFDictionary
    }
}
