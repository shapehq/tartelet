import VirtualMachineDomain

public struct TartVirtualMachineSourceNameRepository: VirtualMachineSourceNameRepository {
    private let tart: Tart

    public init(tart: Tart) {
        self.tart = tart
    }

    public func sourceNames() async throws -> [String] {
        try await tart.list()
    }
}
