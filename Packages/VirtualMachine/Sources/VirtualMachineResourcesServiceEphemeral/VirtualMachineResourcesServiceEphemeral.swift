import FileSystem
import Foundation
import GitHubCredentialsStore
import GitHubService
import VirtualMachineResourcesCopier
import VirtualMachineResourcesService

private enum VirtualMachineResourcesServiceEphemeralError: LocalizedError {
    case organizationNameUnavailable
    case invalidRunnerURL

    var errorDescription: String? {
        switch self {
        case .organizationNameUnavailable:
            return "The organization name is unavailable"
        case .invalidRunnerURL:
            return "The runner URL is invalid. Ensure the organization name is correct"
        }
    }
}

public struct VirtualMachineResourcesServiceEphemeral: VirtualMachineResourcesService {
    private enum ResourceFilename {
        static let runnerName = "RUNNER_NAME"
        static let runnerURL = "RUNNER_URL"
        static let runnerToken = "RUNNER_TOKEN"
        static let runnerDownloadURL = "RUNNER_DOWNLOAD_URL"
        static let runnerLabels = "RUNNER_LABELS"
        static let runnerGroup = "RUNNER_GROUP"
    }

    public var directoryURL: URL {
        fileSystem
            .applicationSupportDirectoryURL
            .appending(path: virtualMachineName.replacingOccurrences(of: ":", with: "_"), directoryHint: .isDirectory)
    }

    private let fileSystem: FileSystem
    private let gitHubService: GitHubService
    private let gitHubCredentialsStore: GitHubCredentialsStore
    private let runnerScope: GitHubRunnerScope
    private let resourcesCopier: VirtualMachineResourcesCopier
    private let editorResourcesDirectoryURL: URL
    private let virtualMachineName: String
    private let runnerLabels: String
    private let runnerGroup: String

    public init(
        fileSystem: FileSystem,
        gitHubService: GitHubService,
        gitHubCredentialsStore: GitHubCredentialsStore,
        runnerScope: GitHubRunnerScope,
        resourcesCopier: VirtualMachineResourcesCopier,
        editorResourcesDirectoryURL: URL,
        virtualMachineName: String,
        runnerLabels: String,
        runnerGroup: String
    ) {
        self.fileSystem = fileSystem
        self.gitHubService = gitHubService
        self.gitHubCredentialsStore = gitHubCredentialsStore
        self.runnerScope = runnerScope
        self.resourcesCopier = resourcesCopier
        self.editorResourcesDirectoryURL = editorResourcesDirectoryURL
        self.virtualMachineName = virtualMachineName
        self.runnerLabels = runnerLabels
        self.runnerGroup = runnerGroup
    }

    public func createResourcesIfNeeded() async throws {
        let runnerURL = try await getRunnerURL()
        let appAccessToken = try await gitHubService.getAppAccessToken(runnerScope: runnerScope)
        let runnerToken = try await gitHubService.getRunnerRegistrationToken(with: appAccessToken, runnerScope: runnerScope)
        let runnerDownloadURL = try await gitHubService.getRunnerDownloadURL(with: appAccessToken, runnerScope: runnerScope)
        try fileSystem.createDirectoryIfNeeded(at: directoryURL)
        if fileSystem.itemExists(at: directoryURL) {
            try resourcesCopier.copyResources(from: editorResourcesDirectoryURL, to: directoryURL)
        }
        let runnerNameFileURL = directoryURL.appending(path: ResourceFilename.runnerName)
        let runnerURLFileURL = directoryURL.appending(path: ResourceFilename.runnerURL)
        let runnerTokenFileURL = directoryURL.appending(path: ResourceFilename.runnerToken)
        let runnerDownloadURLFileURL = directoryURL.appending(path: ResourceFilename.runnerDownloadURL)
        let runnerLabelsFileURL = directoryURL.appending(path: ResourceFilename.runnerLabels)
        let runnerGroupFileURL = directoryURL.appending(path: ResourceFilename.runnerGroup)
        try virtualMachineName.write(to: runnerNameFileURL, atomically: true, encoding: .utf8)
        try runnerURL.absoluteString.write(to: runnerURLFileURL, atomically: true, encoding: .utf8)
        try runnerToken.rawValue.write(to: runnerTokenFileURL, atomically: true, encoding: .utf8)
        try runnerDownloadURL.absoluteString.write(to: runnerDownloadURLFileURL, atomically: true, encoding: .utf8)
        try runnerLabels.write(to: runnerLabelsFileURL, atomically: true, encoding: .utf8)
        try runnerGroup.write(to: runnerGroupFileURL, atomically: true, encoding: .utf8)
        if let resourcesDirectoryURL = Bundle.module.resourceURL?.appending(path: "Resources") {
            try resourcesCopier.copyResources(from: resourcesDirectoryURL, to: directoryURL)
        }
    }

    public func removeResources() throws {
        if fileSystem.itemExists(at: directoryURL) {
            try fileSystem.removeItem(at: directoryURL)
        }
    }
}

private extension VirtualMachineResourcesServiceEphemeral {
    private func getRunnerURL() async throws -> URL {
        let baseURL = await gitHubCredentialsStore.selfHostedURL ?? .gitHub
        switch runnerScope {
        case .organization:
            let organizationName = try await getOrganizationName()
            return baseURL.appending(path: organizationName, directoryHint: .notDirectory)
        case .repo:
            guard
                let ownerName = await gitHubCredentialsStore.ownerName,
                let repositoryName = await gitHubCredentialsStore.repositoryName
            else {
                throw VirtualMachineResourcesServiceEphemeralError.invalidRunnerURL
            }
            return baseURL.appending(path: "\(ownerName)/\(repositoryName)", directoryHint: .notDirectory)
        case .enterpriseServer:
            guard let enterpriseName = await gitHubCredentialsStore.enterpriseName else {
                throw VirtualMachineResourcesServiceEphemeralError.invalidRunnerURL
            }
//            SEE https://docs.github.com/en/enterprise-server@3.10/rest/actions/self-hosted-runners?apiVersion=2022-11-28#create-a-registration-token-for-an-enterprise
            return baseURL.appending(path: enterpriseName, directoryHint: .notDirectory)
        }
    }

    private func getOrganizationName() async throws -> String {
        if let organizationName = await gitHubCredentialsStore.organizationName {
            return organizationName
        } else {
            throw VirtualMachineResourcesServiceEphemeralError.organizationNameUnavailable
        }
    }
}

private extension URL {
    static let gitHub = URL(string: "https://github.com/")!
}
