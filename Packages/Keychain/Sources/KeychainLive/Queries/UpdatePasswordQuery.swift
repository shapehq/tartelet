import Foundation

struct UpdatePasswordQuery: KeychainQuery {
    let password: Data

    var rawQuery: CFDictionary {
        var query: [String: Any] = [:]
        query[kSecValueData as String] = password
        return query as CFDictionary
    }
}
