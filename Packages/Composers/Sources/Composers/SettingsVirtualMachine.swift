import SettingsDomain
import VirtualMachineData
import VirtualMachineDomain

public struct SettingsVirtualMachine<SettingsStoreType: SettingsStore>: VirtualMachineDomain.VirtualMachine {
    public var name: String {
        switch settingsStore.virtualMachine {
        case let .virtualMachine(name):
            return name
        case .unknown:
            fatalError("Cannot get name of virtual machine because none has been selected in settings")
        }
    }
    public var canStart: Bool {
        switch settingsStore.virtualMachine {
        case .virtualMachine:
            return true
        case .unknown:
            return false
        }
    }

    public let tart: Tart
    public let settingsStore: SettingsStoreType

    private var virtualMachine: VirtualMachineDomain.VirtualMachine {
        TartVirtualMachine(tart: tart, vmName: name)
    }

    public func start() async throws {
        try await virtualMachine.start()
    }

    public func clone(named newName: String) async throws -> VirtualMachineDomain.VirtualMachine {
        try await virtualMachine.clone(named: newName)
    }

    public func delete() async throws {
        try await virtualMachine.delete()
    }

    public func getIPAddress() async throws -> String {
        try await virtualMachine.getIPAddress()
    }
}
