import Foundation

struct ReadPasswordQuery: KeychainQuery {
    let accessGroup: String?
    let service: String
    let account: String

    var rawQuery: CFDictionary {
        var query: [String: Any] = [:]
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrAccount as String] = account
        query[kSecAttrService as String] = service
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnData as String] = true
        if let accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        return query as CFDictionary
    }
}
