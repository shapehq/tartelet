import Foundation
import SwiftJWT

public enum GitHubJWTTokenFactory {
    private struct Claims: SwiftJWT.Claims {
        let iss: String
        let iat: Date
        let exp: Date
    }

    public static func makeJWTToken(privateKey: Data, appID: String) throws -> String {
        let now = floor(Date().timeIntervalSince1970)
        let date = Date(timeIntervalSince1970: now)
        let myClaims = Claims(
            iss: appID,
            iat: date.addingTimeInterval(-10),
            exp: date.addingTimeInterval(60)
        )
        var jwt = JWT(claims: myClaims)
        let jwtSigner = JWTSigner.rs256(privateKey: privateKey)
        return try jwt.sign(using: jwtSigner)
    }
}
