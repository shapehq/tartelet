import Citadel
import LoggingDomain
import SSHDomain

struct CitadelSSHConnection: SSHConnection {
    let client: Citadel.SSHClient
    let logger: Logger

    func executeCommand(_ command: String) async throws {
        let outputs = try await client.executeCommandStream(command, inShell: false)
        for try await output in outputs {
            switch output {
            case let .stdout(buffer):
                let string = String(buffer: buffer)
                logger.info(string)
            case let .stderr(buffer):
                let string = String(buffer: buffer)
                logger.error(string)
            }
        }
    }

    func close() async throws {
        try await client.close()
    }
}
