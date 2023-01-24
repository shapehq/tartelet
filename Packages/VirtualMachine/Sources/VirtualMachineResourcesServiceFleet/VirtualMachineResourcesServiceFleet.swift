import FileSystem
import Foundation
import GitHubService
import VirtualMachineResourcesService

public struct VirtualMachineResourcesServiceFleet: VirtualMachineResourcesService {
    public var directoryURL: URL {
        fileSystem
            .applicationSupportDirectoryURL
            .appending(path: "Virtual Machine Resources", directoryHint: .isDirectory)
    }

    private let fileSystem: FileSystem
    private let gitHubService: GitHubService

    public init(fileSystem: FileSystem, gitHubService: GitHubService) {
        self.fileSystem = fileSystem
        self.gitHubService = gitHubService
    }

    public func createResourcesIfNeeded() async throws {
        do {
            try fileSystem.createDirectoryIfNeeded(at: directoryURL)
            let runnerDownloadURL = try await gitHubService.getRunnerDownloadURL()
            let runnerDownloadURLFileURL = directoryURL.appending(path: "RUNNER_DOWNLOAD_URL")
            try runnerDownloadURL.absoluteString.write(to: runnerDownloadURLFileURL, atomically: true, encoding: .utf8)
        } catch {
            print(error)
            throw error
        }
    }
}
