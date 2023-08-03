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
    }

    public var directoryURL: URL {
        fileSystem
            .applicationSupportDirectoryURL
            .appending(path: virtualMachineName.replacingOccurrences(of: ":", with: "_"), directoryHint: .isDirectory)
    }

    private let fileSystem: FileSystem
    private let gitHubService: GitHubService
    private let gitHubCredentialsStore: GitHubCredentialsStore
    private let resourcesCopier: VirtualMachineResourcesCopier
    private let editorResourcesDirectoryURL: URL
    private let virtualMachineName: String
    private let runnerLabels: String

    public init(
        fileSystem: FileSystem,
        gitHubService: GitHubService,
        gitHubCredentialsStore: GitHubCredentialsStore,
        resourcesCopier: VirtualMachineResourcesCopier,
        editorResourcesDirectoryURL: URL,
        virtualMachineName: String,
        runnerLabels: String
    ) {
        self.fileSystem = fileSystem
        self.gitHubService = gitHubService
        self.gitHubCredentialsStore = gitHubCredentialsStore
        self.resourcesCopier = resourcesCopier
        self.editorResourcesDirectoryURL = editorResourcesDirectoryURL
        self.virtualMachineName = virtualMachineName
        self.runnerLabels = runnerLabels
    }

    public func createResourcesIfNeeded() async throws {
        let runnerURL = try await getRunnerURL()
        let appAccessToken = try await gitHubService.getAppAccessToken()
        let runnerToken = try await gitHubService.getRunnerRegistrationToken(with: appAccessToken)
        let runnerDownloadURL = try await gitHubService.getRunnerDownloadURL(with: appAccessToken)
        try fileSystem.createDirectoryIfNeeded(at: directoryURL)
        if fileSystem.itemExists(at: directoryURL) {
            try resourcesCopier.copyResources(from: editorResourcesDirectoryURL, to: directoryURL)
        }
        let runnerNameFileURL = directoryURL.appending(path: ResourceFilename.runnerName)
        let runnerURLFileURL = directoryURL.appending(path: ResourceFilename.runnerURL)
        let runnerTokenFileURL = directoryURL.appending(path: ResourceFilename.runnerToken)
        let runnerDownloadURLFileURL = directoryURL.appending(path: ResourceFilename.runnerDownloadURL)
        let runnerLabelsFileURL = directoryURL.appending(path: ResourceFilename.runnerLabels)
        try virtualMachineName.write(to: runnerNameFileURL, atomically: true, encoding: .utf8)
        try runnerURL.absoluteString.write(to: runnerURLFileURL, atomically: true, encoding: .utf8)
        try runnerToken.rawValue.write(to: runnerTokenFileURL, atomically: true, encoding: .utf8)
        try runnerDownloadURL.absoluteString.write(to: runnerDownloadURLFileURL, atomically: true, encoding: .utf8)
        try runnerLabels.write(to: runnerLabelsFileURL, atomically: true, encoding: .utf8)
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
        let organizationName = try await getOrganizationName()
        guard let runnerURL = URL(string: "https://github.com/" + organizationName) else {
            throw VirtualMachineResourcesServiceEphemeralError.invalidRunnerURL
        }
        return runnerURL
    }

    private func getOrganizationName() async throws -> String {
        if let organizationName = await gitHubCredentialsStore.organizationName {
            return organizationName
        } else {
            throw VirtualMachineResourcesServiceEphemeralError.organizationNameUnavailable
        }
    }
}
