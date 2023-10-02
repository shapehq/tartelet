import Foundation

public protocol GitHubService {
    func getAppAccessToken(runnerScope: GitHubRunnerScope) async throws -> GitHubAppAccessToken
    func getRunnerRegistrationToken(
      with appAccessToken: GitHubAppAccessToken,
      runnerScope: GitHubRunnerScope
    ) async throws -> GitHubRunnerRegistrationToken
    func downloadRunner(
        with appAccessToken: GitHubAppAccessToken,
        runnerScope: GitHubRunnerScope,
        toDirectory cacheDirectoryURL: URL
    ) async throws -> URL
}
