import FileSystem
import Foundation
import GitHubCredentialsStore
import GitHubService
import SettingsStore
import VirtualMachineResourcesCopier
import VirtualMachineResourcesService
import VirtualMachineResourcesServiceEphemeral

struct EphemeralVirtualMachineResourcesServiceFactory: VirtualMachineResourcesServiceFactory {
    let fileSystem: FileSystem
    let settingsStore: SettingsStore
    let gitHubService: GitHubService
    let gitHubCredentialsStore: GitHubCredentialsStore
    let resourcesCopier: VirtualMachineResourcesCopier
    let editorResourcesDirectoryURL: URL

    func makeService(virtualMachineName: String) -> VirtualMachineResourcesService {
        VirtualMachineResourcesServiceEphemeral(
            fileSystem: fileSystem,
            gitHubService: gitHubService,
            gitHubCredentialsStore: gitHubCredentialsStore,
            resourcesCopier: resourcesCopier,
            editorResourcesDirectoryURL: editorResourcesDirectoryURL,
            virtualMachineName: virtualMachineName,
            runnerLabels: settingsStore.gitHubRunnerLabels,
            runnerGroup: settingsStore.gitHubRunnerGroup
        )
    }
}
