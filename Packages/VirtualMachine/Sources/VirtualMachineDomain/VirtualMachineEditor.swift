import Foundation
import LoggingDomain

@Observable
public final class VirtualMachineEditor {
    public private(set) var isStarted = false

    private let logger: Logger
    private let virtualMachine: VirtualMachine
    @ObservationIgnored
    private var runTask: Task<(), Error>? {
        didSet {
            isStarted = runTask != nil
        }
    }

    public init(logger: Logger, virtualMachine: VirtualMachine) {
        self.logger = logger
        self.virtualMachine = virtualMachine
    }

    public func start() {
        guard runTask == nil else {
            return
        }
        logger.info("Will start virtual machine editor...")
        runTask = Task {
            try await withTaskCancellationHandler {
                defer {
                    self.runTask = nil
                }
                try await virtualMachine.start()
            } onCancel: {
                self.stop()
            }
        }
    }

    public func stop() {
        guard runTask != nil else {
            return
        }
        runTask?.cancel()
        runTask = Task {
            self.runTask = nil
            self.logger.info("Did stop virtual machine editor")
        }
    }
}
