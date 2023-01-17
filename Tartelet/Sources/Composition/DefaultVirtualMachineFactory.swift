import FileSystem
import Foundation
import SettingsStore
import Tart
import TartVirtualMachine
import VirtualMachine
import VirtualMachineFactory
import VirtualMachineResourcesService

enum DefaultVirtualMachineFactoryError: LocalizedError {
    case sourceVirtualMachineNameUnavailable

    var errorDescription: String? {
        switch self {
        case .sourceVirtualMachineNameUnavailable:
            return "The source virtual machine name is unavailable. Please select a virtual machine in settings."
        }
    }
}

struct DefaultVirtualMachineFactory: VirtualMachineFactory {
    let tart: Tart
    let settingsStore: SettingsStore
    let resourcesService: VirtualMachineResourcesService

    func makeVirtualMachine() throws -> VirtualMachine {
        guard case let .virtualMachine(sourceVMName) = settingsStore.virtualMachine else {
            throw DefaultVirtualMachineFactoryError.sourceVirtualMachineNameUnavailable
        }
        let resourcesDirectoryURL = resourcesService.directoryURL
        return TartVirtualMachine(tart: tart, sourceVMName: sourceVMName, resourcesDirectoryURL: resourcesDirectoryURL)
    }
}
