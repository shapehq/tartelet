import GitHubDomain

public protocol GitHubActionsRunnerConfiguration {
    var runnerDisableUpdates: Bool { get }
    var runnerScope: GitHubRunnerScope { get }
    var runnerLabels: String { get }
    var runnerGroup: String { get }
    var runnerName: String { get }
}
