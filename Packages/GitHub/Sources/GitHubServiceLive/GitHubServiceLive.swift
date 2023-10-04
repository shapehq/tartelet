import Foundation
import GitHubCredentialsStore
import GitHubJWTTokenFactory
import GitHubService
import NetworkingService

private enum GitHubServiceLiveError: LocalizedError {
    case organizationNameUnavailable
    case repositoryNameUnavailable
    case repositoryOwnerNameUnavailable
    case enterpriseNameUnavailable
    case appIDUnavailable
    case privateKeyUnavailable
    case appIsNotInstalled
    case downloadNotFound(os: String, architecture: String)

    var errorDescription: String? {
        switch self {
        case .organizationNameUnavailable:
            return "The organization name is not available"
        case .repositoryNameUnavailable:
            return "The repository name is not available"
        case .repositoryOwnerNameUnavailable:
            return "The repository owner name is not available"
        case .enterpriseNameUnavailable:
            return "The enterprise name is not available"
        case .appIDUnavailable:
            return "The app ID is not available"
        case .privateKeyUnavailable:
            return "The private key is not available"
        case .appIsNotInstalled:
            return "The GitHub app has not been installed. Please install it from the developer settings."
        case let .downloadNotFound(os, architecture):
            return "Could not find a download for \(os) (\(architecture))"
        }
    }
}

public final class GitHubServiceLive: GitHubService {
    private var baseURL: URL {
        get async {
            await credentialsStore.selfHostedURL ?? .gitHub
        }
    }
    private let credentialsStore: GitHubCredentialsStore
    private let networkingService: NetworkingService

    public init(credentialsStore: GitHubCredentialsStore, networkingService: NetworkingService) {
        self.credentialsStore = credentialsStore
        self.networkingService = networkingService
    }

    public func getAppAccessToken(runnerScope: GitHubRunnerScope) async throws -> GitHubAppAccessToken {
        let appInstallation = try await getAppInstallation(runnerScope: runnerScope)
        let installationID = String(appInstallation.id)
        let appID = String(appInstallation.appId)
        let url = await baseURL.appending(path: "/app/installations/\(installationID)/access_tokens")
        guard let privateKey = await credentialsStore.privateKey else {
            throw GitHubServiceLiveError.privateKeyUnavailable
        }
        let jwtToken = try GitHubJWTTokenFactory.makeJWTToken(privateKey: privateKey, appID: appID)
        var request = URLRequest(url: url).addingBearerToken(jwtToken)
        request.httpMethod = "POST"
        return try await networkingService.load(IntermediateGitHubAppAccessToken.self, from: request).map { parameters in
            GitHubAppAccessToken(parameters.value.token)
        }
    }

    public func getRunnerDownloadURL(with appAccessToken: GitHubAppAccessToken, runnerScope: GitHubRunnerScope) async throws -> URL {
        let url = try await baseURL.appending(path: runnerScope.runnerDownloadPath(using: credentialsStore))
        let request = URLRequest(url: url).addingBearerToken(appAccessToken.rawValue)
        let downloads = try await networkingService.load([GitHubRunnerDownload].self, from: request).map(\.value)
        let os = "osx"
        let architecture = "arm64"
        guard let download = downloads.first(where: { $0.os == os && $0.architecture == architecture }) else {
            throw GitHubServiceLiveError.downloadNotFound(os: os, architecture: architecture)
        }
        return download.downloadURL
    }

    public func getRunnerRegistrationToken(
      with appAccessToken: GitHubAppAccessToken,
      runnerScope: GitHubRunnerScope
    ) async throws -> GitHubRunnerRegistrationToken {
        let url = try await baseURL.appending(path: runnerScope.runnerRegistrationPath(using: credentialsStore))
        var request = URLRequest(url: url).addingBearerToken(appAccessToken.rawValue)
        request.httpMethod = "POST"
        return try await networkingService.load(IntermediateGitHubRunnerRegistrationToken.self, from: request).map { parameters in
            GitHubRunnerRegistrationToken(parameters.value.token)
        }
    }
}

private extension GitHubServiceLive {
    private func getAppInstallation(runnerScope: GitHubRunnerScope) async throws -> GitHubAppInstallation {
        let url = await baseURL.appending(path: "/app/installations")
        let token = try await getAppJWTToken()
        let request = URLRequest(url: url).addingBearerToken(token)
        let appInstallations = try await networkingService.load([GitHubAppInstallation].self, from: request).map(\.value)
        let loginName = await runnerScope.runnerLogin(using: credentialsStore)
        guard let appInstallation = appInstallations.first(where: { $0.account.login == loginName }) else {
            throw GitHubServiceLiveError.appIsNotInstalled
        }
        return appInstallation
    }

    private func getAppJWTToken() async throws -> String {
        guard let privateKey = await credentialsStore.privateKey else {
            throw GitHubServiceLiveError.privateKeyUnavailable
        }
        guard let appID = await credentialsStore.appId else {
            throw GitHubServiceLiveError.appIDUnavailable
        }
        return try GitHubJWTTokenFactory.makeJWTToken(privateKey: privateKey, appID: appID)
    }
}

private extension URL {
    static let gitHub = URL(string: "https://api.github.com")!
}

private extension URLRequest {
    func addingBearerToken(_ token: String) -> URLRequest {
        var mutableRequest = self
        mutableRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return mutableRequest
    }
}

private extension GitHubRunnerScope {
    func runnerRegistrationPath(using credentialsStore: GitHubCredentialsStore) async throws -> String {
        switch self {
        case .organization:
            guard let organizationName = await credentialsStore.organizationName else {
                throw GitHubServiceLiveError.organizationNameUnavailable
            }
            return "/orgs/\(organizationName)/actions/runners/registration-token"
        case .repo:
            guard let repositoryName = await credentialsStore.repositoryName else {
                throw GitHubServiceLiveError.repositoryNameUnavailable
            }
            guard let ownerName = await credentialsStore.ownerName else {
                throw GitHubServiceLiveError.repositoryOwnerNameUnavailable
            }

            return "/repos/\(ownerName)/\(repositoryName)/actions/runners/registration-token"
        case .enterpriseServer:
          guard let enterpriseName = await credentialsStore.enterpriseName else {
              throw GitHubServiceLiveError.enterpriseNameUnavailable
          }
          return "/enterprises/\(enterpriseName)/actions/runners/registration-token"
        }
    }

    func runnerDownloadPath(using credentialsStore: GitHubCredentialsStore) async throws -> String {
        switch self {
        case .organization:
            guard let organizationName = await credentialsStore.organizationName else {
                throw GitHubServiceLiveError.organizationNameUnavailable
            }
            return "/orgs/\(organizationName)/actions/runners/downloads"
        case .repo:
            guard let repositoryName = await credentialsStore.repositoryName else {
                throw GitHubServiceLiveError.repositoryNameUnavailable
            }
            guard let ownerName = await credentialsStore.ownerName else {
                throw GitHubServiceLiveError.repositoryOwnerNameUnavailable
            }

            return "/repos/\(ownerName)/\(repositoryName)/actions/runners/downloads"
        case .enterpriseServer:
            guard let enterpriseName = await credentialsStore.enterpriseName else {
                throw GitHubServiceLiveError.enterpriseNameUnavailable
            }
            return "/enterprises/\(enterpriseName)/actions/runners/downloads"
        }
    }

    func runnerLogin(using credentialsStore: GitHubCredentialsStore) async -> String? {
      switch self {
      case .organization:
        return await credentialsStore.organizationName
      case .repo:
        return await credentialsStore.ownerName
      case .enterpriseServer:
          return await credentialsStore.enterpriseName
      }
    }
}
