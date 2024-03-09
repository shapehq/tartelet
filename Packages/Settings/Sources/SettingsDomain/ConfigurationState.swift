import GitHubDomain
import VirtualMachineDomain

public enum ConfigurationState {
    case ready
    case missingVirtualMachine
    case missingSSHCredentials
    case missingGitHubAppId
    case missingGitHubPrivateKey
    case missingGitHubOrganizationName
    case missingGitHubOwnerName
    case missingGitHubRepositoryName

    public init(
        settingsStore: some SettingsStore,
        virtualMachineSSHCredentialsStore: VirtualMachineSSHCredentialsStore,
        githubCredentialsStore: GitHubCredentialsStore
    ) {
        if case .unknown = settingsStore.virtualMachine {
            self = .missingVirtualMachine
        } else if (virtualMachineSSHCredentialsStore.username ?? "").isEmpty {
            self = .missingSSHCredentials
        } else if (virtualMachineSSHCredentialsStore.password ?? "").isEmpty {
            self = .missingSSHCredentials
        } else if (githubCredentialsStore.appId ?? "").isEmpty {
            self = .missingGitHubAppId
        } else if githubCredentialsStore.privateKey == nil {
            self = .missingGitHubPrivateKey
        } else if settingsStore.githubRunnerScope == .organization
                    && (githubCredentialsStore.organizationName ?? "").isEmpty {
            self = .missingGitHubOrganizationName
        } else if settingsStore.githubRunnerScope == .repo
                    && (githubCredentialsStore.ownerName ?? "").isEmpty {
            self = .missingGitHubOwnerName
        } else if settingsStore.githubRunnerScope == .repo
                    && (githubCredentialsStore.repositoryName ?? "").isEmpty {
            self = .missingGitHubRepositoryName
        } else {
            self = .ready
        }
    }
}

public extension ConfigurationState {
    var shortInstruction: String {
        switch self {
        case .ready:
            L10n.Settings.ConfigurationState.Ready.shortInstruction
        case .missingVirtualMachine:
            L10n.Settings.ConfigurationState.MissingVirtualMachine.shortInstruction
        case .missingSSHCredentials:
            L10n.Settings.ConfigurationState.MissingSshCredentials.shortInstruction
        case .missingGitHubAppId:
            L10n.Settings.ConfigurationState.MissingGithubAppId.shortInstruction
        case .missingGitHubPrivateKey:
            L10n.Settings.ConfigurationState.MissingGithubPrivateKey.shortInstruction
        case .missingGitHubOrganizationName:
            L10n.Settings.ConfigurationState.MissingGithubOrganizationName.shortInstruction
        case .missingGitHubOwnerName:
            L10n.Settings.ConfigurationState.MissingGithubOwnerName.shortInstruction
        case .missingGitHubRepositoryName:
            L10n.Settings.ConfigurationState.MissingGithubRepositoryName.shortInstruction
        }
    }
}
