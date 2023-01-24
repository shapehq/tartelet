import Combine
import SettingsStore
import VirtualMachineFleet
import VirtualMachineFleetFactory
import VirtualMachineResourcesService

public final class VirtualMachineFleetService {
    public let isStarted: AnyPublisher<Bool, Never>

    private let fleetFactory: VirtualMachineFleetFactory
    private let resourcesService: VirtualMachineResourcesService
    private var fleet = CurrentValueSubject<VirtualMachineFleet?, Never>(nil)

    public init(fleetFactory: VirtualMachineFleetFactory, resourcesService: VirtualMachineResourcesService) {
        self.fleetFactory = fleetFactory
        self.resourcesService = resourcesService
        self.isStarted = fleet.map { $0 != nil }.eraseToAnyPublisher()
    }

    public func start() async throws {
        guard fleet.value == nil else {
            return
        }
        try await resourcesService.createResourcesIfNeeded()
        try await MainActor.run {
            fleet.value = try fleetFactory.makeFleet()
            fleet.value?.start()
        }
    }

    public func stop() {
        fleet.value?.stop()
        fleet.value = nil
    }
}
