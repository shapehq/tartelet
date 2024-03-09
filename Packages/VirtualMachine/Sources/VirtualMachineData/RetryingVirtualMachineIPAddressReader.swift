import VirtualMachineDomain

public struct RetryingVirtualMachineIPAddressReader: VirtualMachineIPAddressReader {
    public init() {}

    public func readIPAddress(of virtualMachine: any VirtualMachine) async throws -> String {
        do {
            try Task.checkCancellation()
            return try await virtualMachine.getIPAddress()
        } catch {
            try Task.checkCancellation()
            try await Task.sleep(for: .seconds(2))
            return try await readIPAddress(of: virtualMachine)
        }
    }
}
