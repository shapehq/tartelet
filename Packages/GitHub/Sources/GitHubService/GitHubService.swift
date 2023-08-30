import Foundation

public protocol GitHubService {
    func getAppAccessToken(runnerScope: GitHubRunnerScope) async throws -> GitHubAppAccessToken
    func getRunnerRegistrationToken(
      with appAccessToken: GitHubAppAccessToken,
      runnerScope: GitHubRunnerScope
    ) async throws -> GitHubRunnerRegistrationToken
    func getRunnerDownloadURL(with appAccessToken: GitHubAppAccessToken, runnerScope: GitHubRunnerScope) async throws -> URL
}
