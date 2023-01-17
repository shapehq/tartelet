import VirtualMachine

public protocol VirtualMachineFactory {
    func makeVirtualMachine() throws -> VirtualMachine
}
