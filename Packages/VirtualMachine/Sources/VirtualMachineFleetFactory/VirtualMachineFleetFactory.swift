import VirtualMachineFleet

public protocol VirtualMachineFleetFactory {
    func makeFleet() throws -> VirtualMachineFleet
}
