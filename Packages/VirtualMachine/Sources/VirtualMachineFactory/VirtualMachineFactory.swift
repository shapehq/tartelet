import VirtualMachine

public protocol VirtualMachineFactory {
    var preferredVirtualMachineName: String { get throws }
    func makeVirtualMachine(named name: String) async throws -> VirtualMachine
}
