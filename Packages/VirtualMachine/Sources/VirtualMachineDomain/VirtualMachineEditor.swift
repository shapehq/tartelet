import Combine
import Foundation
import LoggingDomain

public final class VirtualMachineEditor {
    public let isStarted: AnyPublisher<Bool, Never>

    private let logger: Logger
    private let virtualMachine: VirtualMachine
    private var runTask = CurrentValueSubject<Task<(), Error>?, Never>(nil)

    public init(logger: Logger, virtualMachine: VirtualMachine) {
        self.logger = logger
        self.virtualMachine = virtualMachine
        self.isStarted = runTask
            .receive(on: DispatchQueue.main)
            .map { $0 != nil }
            .eraseToAnyPublisher()
    }

    public func start() {
        guard runTask.value == nil else {
            return
        }
        logger.info("Will start virtual machine editor...")
        runTask.value = Task {
            try await withTaskCancellationHandler {
                defer {
                    self.runTask.value = nil
                }
                try await virtualMachine.start()
            } onCancel: {
                self.stop()
            }
        }
    }

    public func stop() {
        guard runTask.value != nil else {
            return
        }
        runTask.value?.cancel()
        runTask.value = Task {
            self.runTask.value = nil
            self.logger.info("Did stop virtual machine editor")
        }
    }
}
