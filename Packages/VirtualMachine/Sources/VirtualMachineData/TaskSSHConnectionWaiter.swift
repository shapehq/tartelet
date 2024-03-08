import VirtualMachineDomain

struct TaskSSHConnectionWaiter: SSHConnectionWaiter {
    func wait(for duration: Duration) async throws {
        try await Task.sleep(for: duration)
    }
}
