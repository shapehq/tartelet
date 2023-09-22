import Combine

public protocol VirtualMachineFleet {
    var isStarted: AnyPublisher<Bool, Never> { get }
    var isStopping: AnyPublisher<Bool, Never> { get }
    func start(numberOfMachines: Int) throws
    func stopImmediately()
    func stop()
}
