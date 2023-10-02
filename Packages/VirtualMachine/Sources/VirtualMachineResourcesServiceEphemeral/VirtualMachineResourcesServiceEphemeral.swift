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
        static let runnerLabels = "RUNNER_LABELS"
        static let runnerGroup = "RUNNER_GROUP"
        static let runnerApplication = "actions-runner.tar.gz"
        static let runnerVersion = "RUNNER_VERSION"
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

    private var runnerCacheDirectoryURL: URL {
        fileSystem
            .applicationSupportDirectoryURL
            .appending(path: "Runner application cache")
    }

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

        let runnerCacheFileURL = runnerCacheDirectoryURL.appending(path: runnerDownloadURL.filename)
        if !fileSystem.itemExists(at: runnerCacheFileURL) {
            try? fileSystem.removeItem(at: runnerCacheDirectoryURL)
            try fileSystem.createDirectoryIfNeeded(at: runnerCacheDirectoryURL)
            let runnerApplication = try await gitHubService.downloadRunner(runnerDownloadURL)
            try runnerApplication.write(to: runnerCacheFileURL)
        }

        try fileSystem.createDirectoryIfNeeded(at: directoryURL)
        if fileSystem.itemExists(at: directoryURL) {
            try resourcesCopier.copyResources(from: editorResourcesDirectoryURL, to: directoryURL)
            let runnerApplicationFileURL = directoryURL.appending(path: ResourceFilename.runnerApplication)
            if fileSystem.itemExists(at: runnerApplicationFileURL) {
                try fileSystem.removeItem(at: runnerApplicationFileURL)
            }
            try fileSystem.copyItem(from: runnerCacheFileURL, to: runnerApplicationFileURL)
        }
        let runnerNameFileURL = directoryURL.appending(path: ResourceFilename.runnerName)
        let runnerURLFileURL = directoryURL.appending(path: ResourceFilename.runnerURL)
        let runnerTokenFileURL = directoryURL.appending(path: ResourceFilename.runnerToken)
        let runnerLabelsFileURL = directoryURL.appending(path: ResourceFilename.runnerLabels)
        let runnerGroupFileURL = directoryURL.appending(path: ResourceFilename.runnerGroup)
        try virtualMachineName.write(to: runnerNameFileURL, atomically: true, encoding: .utf8)
        try runnerURL.absoluteString.write(to: runnerURLFileURL, atomically: true, encoding: .utf8)
        try runnerToken.rawValue.write(to: runnerTokenFileURL, atomically: true, encoding: .utf8)
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
        switch runnerScope {
        case .organization:
            let organizationName = try await getOrganizationName()
            guard let runnerURL = URL(string: "https://github.com/" + organizationName) else {
                throw VirtualMachineResourcesServiceEphemeralError.invalidRunnerURL
            }
            return runnerURL
        case .repo:
            guard
                let ownerName = await gitHubCredentialsStore.ownerName,
                let repositoryName = await gitHubCredentialsStore.repositoryName,
                let runnerURL = URL(string: "https://github.com/\(ownerName)/\(repositoryName)")
            else {
                throw VirtualMachineResourcesServiceEphemeralError.invalidRunnerURL
            }
            return runnerURL
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
