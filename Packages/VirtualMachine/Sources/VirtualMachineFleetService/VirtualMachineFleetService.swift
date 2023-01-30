import Combine
import SettingsStore
import VirtualMachineFleet
import VirtualMachineFleetFactory
import VirtualMachineResourcesService

public final class VirtualMachineFleetService {
    public let isStarted: AnyPublisher<Bool, Never>

    private let fleetFactory: VirtualMachineFleetFactory
    private var fleet = CurrentValueSubject<VirtualMachineFleet?, Never>(nil)

    public init(fleetFactory: VirtualMachineFleetFactory) {
        self.fleetFactory = fleetFactory
        self.isStarted = fleet.map { $0 != nil }.eraseToAnyPublisher()
    }

    public func start() async throws {
        guard fleet.value == nil else {
            return
        }
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
