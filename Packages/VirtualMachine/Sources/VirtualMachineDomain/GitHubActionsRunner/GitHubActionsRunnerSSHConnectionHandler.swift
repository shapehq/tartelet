import Foundation
import GitHubDomain
import LoggingDomain
import SSHDomain

private enum GitHubActionsRunnerSSHConnectionHandlerError: LocalizedError {
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

public struct GitHubActionsRunnerSSHConnectionHandler: VirtualMachineSSHConnectionHandler {
    private let logger: Logger
    private let client: GitHubClient
    private let credentialsStore: GitHubCredentialsStore
    private let configuration: GitHubActionsRunnerConfiguration

    public init(
        logger: Logger,
        client: GitHubClient,
        credentialsStore: GitHubCredentialsStore,
        configuration: GitHubActionsRunnerConfiguration
    ) {
        self.logger = logger
        self.client = client
        self.credentialsStore = credentialsStore
        self.configuration = configuration
    }

    // swiftlint:disable:next function_body_length
    public func didConnect(to virtualMachine: VirtualMachine, through connection: SSHConnection) async throws {
        let runnerURL = try await getRunnerURL()
        let appAccessToken = try await client.getAppAccessToken(runnerScope: configuration.runnerScope)
        let runnerToken = try await client.getRunnerRegistrationToken(
            with: appAccessToken,
            runnerScope: configuration.runnerScope
        )
        let runnerDownloadURL = try await client.getRunnerDownloadURL(
            with: appAccessToken,
            runnerScope: configuration.runnerScope
        )
        let bootScriptFilePath = "~/boot.sh"
        try await connection.executeCommand("touch \(bootScriptFilePath)")
        try await connection.executeCommand("""
cat > \(bootScriptFilePath) << EOF
#!/bin/zsh
ACTIONS_RUNNER_ARCHIVE=./actions-runner.tar.gz
ACTIONS_RUNNER_DIRECTORY=~/actions-runner

# Ensure the virtual machine is restarted when a job is done.
set -e pipefail
function onexit {
  sudo shutdown -h now
}
trap onexit EXIT

# Wait until we can connect to GitHub.
until curl -Is https://github.com &>/dev/null; do :; done

# Download the runner if the runner directory and
# archive does not already exist.
if [ ! -d \\$ACTIONS_RUNNER_DIRECTORY ]; then
  if [ ! -f \\$ACTIONS_RUNNER_ARCHIVE ]; then
    curl -o \\$ACTIONS_RUNNER_ARCHIVE -L "\(runnerDownloadURL)"
    # Unarchive the runner.
    mkdir -p \\$ACTIONS_RUNNER_DIRECTORY
    tar xzf \\$ACTIONS_RUNNER_ARCHIVE --directory \\$ACTIONS_RUNNER_DIRECTORY
  fi
fi

# Holds environment passed to runner.
RUNNER_ENV=""

# Configure pre-run script.
PRE_RUN_SCRIPT_PATH="\\$HOME/.tartelet/pre-run.sh"
if [ -f "\\$PRE_RUN_SCRIPT_PATH" ]; then
  RUNNER_ENV="\\${RUNNER_ENV}ACTIONS_RUNNER_HOOK_JOB_STARTED=\\${PRE_RUN_SCRIPT_PATH}\n"
fi

# Configure post-run script.
POST_RUN_SCRIPT_PATH="\\$HOME/.tartelet/post-run.sh"
if [ -f "\\$POST_RUN_SCRIPT_PATH" ]; then
  RUNNER_ENV="\\${RUNNER_ENV}ACTIONS_RUNNER_HOOK_JOB_COMPLETED=\\${POST_RUN_SCRIPT_PATH}\n"
fi

# Create .env file in runner's diectory.
if [ "\\$RUNNER_ENV" != "" ]; then
  echo \\$RUNNER_ENV > \\$ACTIONS_RUNNER_DIRECTORY/.env
fi

# Configure and run the runner.
cd \\$ACTIONS_RUNNER_DIRECTORY
./config.sh\\\\
  --url "\(runnerURL)"\\\\
  --unattended\\\\
  --ephemeral\\\\
  --replace\\\\
  --labels "\(configuration.runnerLabels)"\\\\
  --name "\(virtualMachine.name)"\\\\
  --runnergroup "\(configuration.runnerGroup)"\\\\
  --work "_work"\\\\
  --token "\(runnerToken.rawValue)"
./run.sh
EOF
""")
        try await connection.executeCommand("chmod +x \(bootScriptFilePath)")
        try await connection.executeCommand("open -a Terminal \(bootScriptFilePath)")
    }
}

private extension GitHubActionsRunnerSSHConnectionHandler {
    private func getRunnerURL() async throws -> URL {
        switch configuration.runnerScope {
        case .organization:
            let organizationName = try await getOrganizationName()
            guard let runnerURL = URL(string: "https://github.com/" + organizationName) else {
                logger.info("Invalid runner URL for organization with name \(organizationName)")
                throw GitHubActionsRunnerSSHConnectionHandlerError.invalidRunnerURL
            }
            return runnerURL
        case .repo:
            guard
                let ownerName = credentialsStore.ownerName,
                let repositoryName = credentialsStore.repositoryName,
                let runnerURL = URL(string: "https://github.com/\(ownerName)/\(repositoryName)")
            else {
                logger.info("Invalid runner URL for repository")
                throw GitHubActionsRunnerSSHConnectionHandlerError.invalidRunnerURL
            }
            return runnerURL
        }
    }

    private func getOrganizationName() async throws -> String {
        guard let organizationName = credentialsStore.organizationName else {
            logger.info("The GitHub organization name is not available")
            throw GitHubActionsRunnerSSHConnectionHandlerError.organizationNameUnavailable
        }
        return organizationName
    }
}
