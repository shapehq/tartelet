import Foundation

public protocol GitHubService {
    func getAppAccessToken() async throws -> GitHubAppAccessToken
    func getRunnerRegistrationToken(with appAccessToken: GitHubAppAccessToken) async throws -> GitHubRunnerRegistrationToken
    func getRunnerDownloadURL(with appAccessToken: GitHubAppAccessToken) async throws -> URL
}
