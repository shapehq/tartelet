import Combine
import Foundation
import LogConsumer
import VirtualMachine
import VirtualMachineFactory
import VirtualMachineResourcesService

public final class VirtualMachineEditorService {
    public let isStarted: AnyPublisher<Bool, Never>

    private let logger: LogConsumer
    private let virtualMachineFactory: VirtualMachineFactory
    private var virtualMachine: VirtualMachine?
    private var runTask = CurrentValueSubject<Task<(), Error>?, Never>(nil)

    public init(logger: LogConsumer, virtualMachineFactory: VirtualMachineFactory) {
        self.logger = logger
        self.virtualMachineFactory = virtualMachineFactory
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
                let preferredName = try virtualMachineFactory.preferredVirtualMachineName
                virtualMachine = try await virtualMachineFactory.makeVirtualMachine(named: preferredName)
                try await virtualMachine?.start()
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
            try? await virtualMachine?.stop()
            self.virtualMachine = nil
            self.runTask.value = nil
            self.logger.info("Did stop virtual machine editor")
        }
    }
}
