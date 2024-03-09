public protocol SSHConnection {
    func executeCommand(_ command: String) async throws
    func close() async throws
}
