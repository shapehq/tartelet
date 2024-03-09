public protocol SSHClient {
    associatedtype SSHConnectionType: SSHConnection
    func connect(host: String, username: String, password: String) async throws -> SSHConnectionType
}
