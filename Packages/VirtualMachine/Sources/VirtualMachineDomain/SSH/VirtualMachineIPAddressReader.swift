public protocol VirtualMachineIPAddressReader {
    func readIPAddress(of virtualMachine: VirtualMachine) async throws -> String
}
