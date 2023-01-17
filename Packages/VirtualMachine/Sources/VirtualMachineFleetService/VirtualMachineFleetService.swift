import Combine
import SettingsStore
import VirtualMachineFleet
import VirtualMachineFleetFactory

public final class VirtualMachineFleetService {
    public let isStarted: AnyPublisher<Bool, Never>

    private let fleetFactory: VirtualMachineFleetFactory
    private var fleet: VirtualMachineFleet?
    private var _isStarted = CurrentValueSubject<Bool, Never>(false)

    public init(fleetFactory: VirtualMachineFleetFactory) {
        self.fleetFactory = fleetFactory
        self.isStarted = _isStarted.eraseToAnyPublisher()
    }

    public func start() throws {
        guard !_isStarted.value else {
            return
        }
        fleet = try fleetFactory.makeFleet()
        fleet?.start()
        _isStarted.value = true
    }

    public func stop() {
        fleet?.stop()
        fleet = nil
        _isStarted.value = false
    }
}
