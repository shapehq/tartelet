import Foundation
import SettingsStore
import Tart
import TartVirtualMachine
import VirtualMachine
import VirtualMachineFactory
import VirtualMachineResourcesService

enum LongLivedVirtualMachineFactoryError: LocalizedError {
    case sourceVirtualMachineNameUnavailable

    var errorDescription: String? {
        switch self {
        case .sourceVirtualMachineNameUnavailable:
            return "The source virtual machine name is unavailable. Please select a virtual machine in settings."
        }
    }
}

struct LongLivedVirtualMachineFactory: VirtualMachineFactory {
    let tart: Tart
    let settingsStore: SettingsStore
    let resourcesService: VirtualMachineResourcesService

    func makeVirtualMachine() throws -> VirtualMachine {
        guard case let .virtualMachine(vmName) = settingsStore.virtualMachine else {
            throw EphemeralVirtualMachineFactoryError.sourceVirtualMachineNameUnavailable
        }
        let resourcesDirectoryURL = resourcesService.directoryURL
        return TartVirtualMachine(
            tart: tart,
            vmName: vmName,
            resourcesDirectoryURL: resourcesDirectoryURL
        )
    }
}
