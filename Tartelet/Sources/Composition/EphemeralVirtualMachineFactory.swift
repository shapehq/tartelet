import EphemeralTartVirtualMachine
import Foundation
import SettingsStore
import Tart
import VirtualMachine
import VirtualMachineFactory
import VirtualMachineResourcesService

enum EphemeralVirtualMachineFactoryError: LocalizedError {
    case sourceVirtualMachineNameUnavailable

    var errorDescription: String? {
        switch self {
        case .sourceVirtualMachineNameUnavailable:
            return "The source virtual machine name is unavailable. Please select a virtual machine in settings."
        }
    }
}

struct EphemeralVirtualMachineFactory: VirtualMachineFactory {
    let tart: Tart
    let settingsStore: SettingsStore
    let resourcesService: VirtualMachineResourcesService

    func makeVirtualMachine() throws -> VirtualMachine {
        guard case let .virtualMachine(sourceVMName) = settingsStore.virtualMachine else {
            throw EphemeralVirtualMachineFactoryError.sourceVirtualMachineNameUnavailable
        }
        let resourcesDirectoryURL = resourcesService.directoryURL
        return EphemeralTartVirtualMachine(
            tart: tart,
            sourceVMName: sourceVMName,
            resourcesDirectoryURL: resourcesDirectoryURL
        )
    }
}
