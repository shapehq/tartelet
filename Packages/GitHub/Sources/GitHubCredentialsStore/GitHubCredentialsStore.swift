import Foundation

public protocol GitHubCredentialsStore: AnyObject {
    var organizationName: String? { get async }
    var appId: String? { get async }
    var privateKey: Data? { get async }
    func setOrganizationName(_ organizationName: String?) async
    func setAppID(_ appID: String?) async
    func setPrivateKey(_ privateKeyData: Data?) async
}
