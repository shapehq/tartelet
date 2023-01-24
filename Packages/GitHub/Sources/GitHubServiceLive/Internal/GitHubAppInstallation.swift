struct GitHubAppInstallation: Codable {
    struct Account: Codable {
        let login: String

        init(login: String) {
            self.login = login
        }
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case appId = "app_id"
        case account
    }

    let id: Int
    let appId: Int
    let account: Account

    init(id: Int, appId: Int, account: Account) {
        self.id = id
        self.appId = appId
        self.account = account
    }
}
