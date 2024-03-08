public protocol SSHConnectionWaiter {
    func wait(for duration: Duration) async throws
}
