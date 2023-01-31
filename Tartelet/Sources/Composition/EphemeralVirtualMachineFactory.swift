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
    var preferredVirtualMachineName: String {
        get throws {
            guard case let .virtualMachine(vmName) = settingsStore.virtualMachine else {
                throw EphemeralVirtualMachineFactoryError.sourceVirtualMachineNameUnavailable
            }
            return vmName
        }
    }

    func makeVirtualMachine(named name: String) async throws -> VirtualMachine {
        guard case let .virtualMachine(sourceVMName) = settingsStore.virtualMachine else {
            throw EphemeralVirtualMachineFactoryError.sourceVirtualMachineNameUnavailable
        }
        let resourcesService = resourcesServiceFactory.makeService(virtualMachineName: name)
        try await resourcesService.createResourcesIfNeeded()
        // swiftlint:disable:next trailing_closure
        return EphemeralTartVirtualMachine(
            tart: tart,
            sourceVMName: sourceVMName,
            destinationVMName: name,
            resourcesDirectoryURL: resourcesService.directoryURL,
            onCleanup: {
                try? resourcesService.removeResources()
            })
    }
}
