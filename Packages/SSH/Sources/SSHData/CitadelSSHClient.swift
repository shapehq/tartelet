import Citadel
import SSHDomain

public final class CitadelSSHClient: SSHDomain.SSHClient {
    public init() {}

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
        return CitadelSSHConnection(client: client)
    }
}
