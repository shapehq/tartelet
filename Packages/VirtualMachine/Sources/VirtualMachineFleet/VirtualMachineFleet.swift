import Combine

public protocol VirtualMachineFleet {
    var isStarted: AnyPublisher<Bool, Never> { get }
    func start(numberOfMachines: Int) throws
    func stop()
}
