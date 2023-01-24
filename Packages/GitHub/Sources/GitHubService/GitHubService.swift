import Foundation

public protocol GitHubService {
    func getRunnerDownloadURL() async throws -> URL
}
