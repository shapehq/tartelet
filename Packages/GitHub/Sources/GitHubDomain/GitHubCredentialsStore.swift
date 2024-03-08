import Foundation

public protocol GitHubCredentialsStore: AnyObject {
    var organizationName: String? { get }
    var repositoryName: String? { get }
    var ownerName: String? { get }
    var appId: String? { get }
    var privateKey: Data? { get }
    func setOrganizationName(_ organizationName: String?)
    func setRepository(_ repositoryName: String?, withOwner ownerName: String?)
    func setAppID(_ appID: String?)
    func setPrivateKey(_ privateKeyData: Data?)
}
