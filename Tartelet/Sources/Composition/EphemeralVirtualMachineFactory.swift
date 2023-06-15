import EphemeralTartVirtualMachine
import Foundation
import LogHelpers
import OSLog
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

    private let logger = Logger(category: "EphemeralVirtualMachineFactory")

    func makeVirtualMachine(named name: String) async throws -> VirtualMachine {
        guard case let .virtualMachine(sourceVMName) = settingsStore.virtualMachine else {
            logger.error("Failed making ephemeral virtual machine as name is not available")
            throw EphemeralVirtualMachineFactoryError.sourceVirtualMachineNameUnavailable
        }
        do {
            let resourcesService = resourcesServiceFactory.makeService(virtualMachineName: name)
            try await resourcesService.createResourcesIfNeeded()
            // swiftlint:disable:next trailing_closure
            return EphemeralTartVirtualMachine(
                tart: tart,
                sourceVMName: sourceVMName,
                destinationVMName: name,
                resourcesDirectoryURL: resourcesService.directoryURL,
                onCleanup: {
                    do {
                        try resourcesService.removeResources()
                    } catch {
                        logger.error("Failed cleaning up resources for ephemeral virtual machine: \(error.localizedDescription, privacy: .public)")
                    }
                })
        } catch {
            logger.error("Failed making ephemeral virtual machine as resources could not be created: \(error.localizedDescription, privacy: .public)")
            throw error
        }
    }
}
