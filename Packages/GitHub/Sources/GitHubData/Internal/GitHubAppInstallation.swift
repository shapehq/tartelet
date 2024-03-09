struct GitHubAppInstallation: Codable {
    struct Account: Codable {
        let login: String
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case appId = "app_id"
        case account
    }

    let id: Int
    let appId: Int
    let account: Account
}
