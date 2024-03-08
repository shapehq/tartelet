import Citadel
import SSHDomain

struct CitadelSSHConnection: SSHConnection {
    let client: Citadel.SSHClient

    func executeCommand(_ command: String) async throws {
        let outputs = try await client.executeCommandStream(command, inShell: false)
        for try await output in outputs {
            switch output {
            case let .stdout(buffer):
                let string = String(buffer: buffer)
                print(string)
            case let .stderr(buffer):
                let string = String(buffer: buffer)
                print(string)
            }
        }
    }

    func close() async throws {
        try await client.close()
    }
}
