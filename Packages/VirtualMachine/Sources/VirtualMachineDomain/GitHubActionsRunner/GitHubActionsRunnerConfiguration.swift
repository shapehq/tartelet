import GitHubDomain

public protocol GitHubActionsRunnerConfiguration {
    var runnerScope: GitHubRunnerScope { get }
    var runnerLabels: String { get }
    var runnerGroup: String { get }
}
