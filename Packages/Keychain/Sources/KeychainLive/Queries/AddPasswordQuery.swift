import Foundation

struct AddPasswordQuery: KeychainQuery {
    let accessGroup: String?
    let service: String
    let account: String
    let password: Data

    var rawQuery: CFDictionary {
        var query: [String: Any] = [:]
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = service
        query[kSecAttrAccount as String] = account
        query[kSecValueData as String] = password
        if let accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        return query as CFDictionary
    }
}
