import Foundation

public protocol GitHubCredentialsStore: AnyObject {
    var organizationName: String? { get async }
    var repositoryName: String? { get async }
    var ownerName: String? { get async }
    var appId: String? { get async }
    var privateKey: Data? { get async }
    func setOrganizationName(_ organizationName: String?) async
    func setRepository(_ repositoryName: String?, withOwner ownerName: String?) async
    func setAppID(_ appID: String?) async
    func setPrivateKey(_ privateKeyData: Data?) async
}
