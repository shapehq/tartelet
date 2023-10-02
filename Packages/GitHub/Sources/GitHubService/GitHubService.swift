import Foundation

public protocol GitHubService {
    func getAppAccessToken(runnerScope: GitHubRunnerScope) async throws -> GitHubAppAccessToken
    func getRunnerRegistrationToken(
      with appAccessToken: GitHubAppAccessToken,
      runnerScope: GitHubRunnerScope
    ) async throws -> GitHubRunnerRegistrationToken
    func getRunnerDownloadURL(with appAccessToken: GitHubAppAccessToken, runnerScope: GitHubRunnerScope) async throws -> GitHubRunnerDownloadURL
    func downloadRunner(_ url: GitHubRunnerDownloadURL) async throws -> Data
}

public protocol GitHubRunnerDownloadURL {
    var downloadURL: URL { get }
    var filename: String { get }
}
