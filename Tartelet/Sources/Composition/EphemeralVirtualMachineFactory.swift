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
    let resourcesServiceFactory: VirtualMachineResourcesServiceFactory
    let destinationVMNameFactory: DestinationVMNameFactory

    func makeVirtualMachine() async throws -> VirtualMachine {
        guard case let .virtualMachine(sourceVMName) = settingsStore.virtualMachine else {
            throw EphemeralVirtualMachineFactoryError.sourceVirtualMachineNameUnavailable
        }
        let destinationVMName = await destinationVMNameFactory.destinationVMName(fromSourceName: sourceVMName)
        let resourcesService = resourcesServiceFactory.makeService(virtualMachineName: destinationVMName)
        try await resourcesService.createResourcesIfNeeded()
        // swiftlint:disable:next trailing_closure
        return EphemeralTartVirtualMachine(
            tart: tart,
            sourceVMName: sourceVMName,
            destinationVMName: destinationVMName,
            resourcesDirectoryURL: resourcesService.directoryURL,
            onCleanup: {
                try? resourcesService.removeResources()
            })
    }
}
