import Foundation
import RSAPrivateKey

public protocol Keychain {
    func setPassword(_ password: Data, forAccount account: String, belongingToService service: String) async -> Bool
    func setPassword(_ password: String, forAccount account: String, belongingToService service: String) async -> Bool
    func password(forAccount account: String, belongingToService service: String) async -> Data?
    func password(forAccount account: String, belongingToService service: String) async -> String?
    func removePassword(forAccount account: String, belongingToService service: String) async
    func setKey(_ key: RSAPrivateKey, withTag tag: String) async -> Bool
    func key(withTag tag: String) async -> RSAPrivateKey?
    func removeKey(withTag tag: String) async
}
