import Citadel
import LoggingDomain
import SSHDomain

public final class CitadelSSHClient: SSHDomain.SSHClient {
    private let logger: Logger

    public init(logger: Logger) {
        self.logger = logger
    }

    public func connect(host: String, username: String, password: String) async throws -> some SSHConnection {
        let client = try await Citadel.SSHClient.connect(
            host: host,
            authenticationMethod: .passwordBased(
                username: username,
                password: password
            ),
            hostKeyValidator: .acceptAnything(),
            reconnect: .never
        )
        return CitadelSSHConnection(client: client, logger: logger)
    }
}
