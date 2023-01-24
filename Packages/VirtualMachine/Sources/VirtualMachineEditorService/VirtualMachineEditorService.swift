import Combine
import Foundation
import VirtualMachine
import VirtualMachineFactory
import VirtualMachineResourcesService

public final class VirtualMachineEditorService {
    public let isStarted: AnyPublisher<Bool, Never>

    private let virtualMachineFactory: VirtualMachineFactory
    private let resourcesService: VirtualMachineResourcesService
    private var virtualMachine: VirtualMachine?
    private var runTask = CurrentValueSubject<Task<(), Error>?, Never>(nil)

    public init(virtualMachineFactory: VirtualMachineFactory, resourcesService: VirtualMachineResourcesService) {
        self.virtualMachineFactory = virtualMachineFactory
        self.resourcesService = resourcesService
        self.isStarted = runTask
            .receive(on: DispatchQueue.main)
            .map { $0 != nil }
            .eraseToAnyPublisher()
    }

    public func start() {
        guard runTask.value == nil else {
            return
        }
        runTask.value = Task {
            try await withTaskCancellationHandler {
                defer {
                    self.runTask.value = nil
                }
                try await resourcesService.createResourcesIfNeeded()
                virtualMachine = try virtualMachineFactory.makeVirtualMachine()
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
        }
    }
}
