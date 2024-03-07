import SettingsDomain
import VirtualMachineData
import VirtualMachineDomain

struct SettingsVirtualMachine<SettingsStoreType: SettingsStore>: VirtualMachineDomain.VirtualMachine {
    var name: String {
        switch settingsStore.virtualMachine {
        case let .virtualMachine(name):
            return name
        case .unknown:
            fatalError("Cannot get name of virtual machine because none has been selected in settings")
        }
    }

    let tart: Tart
    let settingsStore: SettingsStoreType

    private var virtualMachine: VirtualMachineDomain.VirtualMachine {
        TartVirtualMachine(tart: tart, vmName: name)
    }

    func start() async throws {
        try await virtualMachine.start()
    }

    func clone(named newName: String) async throws -> VirtualMachineDomain.VirtualMachine {
        try await virtualMachine.clone(named: newName)
    }

    func delete() async throws {
        try await virtualMachine.delete()
    }
}
