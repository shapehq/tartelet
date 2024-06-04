import Foundation

public final class RSAPrivateKey {
    public let rawValue: SecKey
    public var data: Data? {
        if let data = _data {
            return data
        } else {
            let data = SecKeyCopyExternalRepresentation(rawValue, nil) as? Data
            _data = data
            return data
        }
    }

    private var _data: Data?

    public convenience init?(contentsOf fileURL: URL) {
        do {
            let data = try Data(contentsOf: fileURL)
            self.init(data)
        } catch {
            return nil
        }
    }

    public convenience init?(_ data: Data) {
        let string = String(decoding: data, as: UTF8.self)
        self.init(string)
    }

    public convenience init?(_ string: String) {
        let stringBody = string
            .replacingOccurrences(of: "-----BEGIN RSA PRIVATE KEY-----", with: "")
            .replacingOccurrences(of: "-----END RSA PRIVATE KEY-----", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\n", with: "")
        guard let body = Data(base64Encoded: stringBody) else {
            return nil
        }
        self.init(body: body)
    }

    public init(_ rawValue: SecKey) {
        self.rawValue = rawValue
    }

    private init?(body: Data) {
        let attributes: [String: Any] = [
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA
        ]
        guard let secKey = SecKeyCreateWithData(body as CFData, attributes as CFDictionary, nil) else {
            return nil
        }
        rawValue = secKey
    }
}
