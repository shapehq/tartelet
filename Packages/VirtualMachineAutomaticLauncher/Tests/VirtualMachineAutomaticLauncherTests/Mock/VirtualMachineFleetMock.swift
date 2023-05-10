import Combine
import Foundation
import VirtualMachineFleet

enum VirtualMachineFleetMockError: LocalizedError {
    case mock

    var errorDescription: String? {
        switch self {
        case .mock:
            return "Mock error"
        }
    }
}

final class VirtualMachineFleetMock: VirtualMachineFleet {
    let isStarted: AnyPublisher<Bool, Never> = CurrentValueSubject(false).eraseToAnyPublisher()
    private(set) var didStartVirtualMachines = false

    private let shouldFailStarting: Bool

    init(shouldFailStarting: Bool = false) {
        self.shouldFailStarting = shouldFailStarting
    }

    func start(numberOfMachines: Int) throws {
        if shouldFailStarting {
            throw VirtualMachineFleetMockError.mock
        } else {
            didStartVirtualMachines = true
        }
    }

    func stop() {}
}
