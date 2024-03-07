import Combine
import GitHubDomain
import SwiftUI

public protocol SettingsStore: ObservableObject {
    var applicationUIMode: ApplicationUIMode { get set }
    var tartHomeFolderURL: URL? { get set }
    var virtualMachine: VirtualMachine { get set }
    var numberOfVirtualMachines: Int { get set }
    var startVirtualMachinesOnLaunch: Bool { get set }
    var gitHubPrivateKeyName: String? { get set }
    var gitHubRunnerLabels: String { get set }
    var gitHubRunnerGroup: String { get set }
    var githubRunnerScope: GitHubRunnerScope { get set }
    var onChange: AnyPublisher<Self, Never> { get }
}
