import VirtualMachine

public protocol VirtualMachineFactory {
    func makeVirtualMachine() async throws -> VirtualMachine
}
