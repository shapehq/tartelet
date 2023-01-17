import Combine
import SettingsStore
import VirtualMachine
import VirtualMachineFactory

public final class VirtualMachineEditorService {
    public let isStarted: AnyPublisher<Bool, Never>

    private let virtualMachineFactory: VirtualMachineFactory
    private var virtualMachine: VirtualMachine?
    private var _isStarted = CurrentValueSubject<Bool, Never>(false)
    private var runTask: Task<(), Error>?

    public init(virtualMachineFactory: VirtualMachineFactory) {
        self.virtualMachineFactory = virtualMachineFactory
        self.isStarted = _isStarted.eraseToAnyPublisher()
    }

    public func start() throws {
        guard !_isStarted.value else {
            return
        }
        _isStarted.value = true
        runTask = Task { [weak self] in
            if let self = self {
                let virtualMachine = try self.virtualMachineFactory.makeVirtualMachine()
                self.virtualMachine = virtualMachine
                do {
                    try await virtualMachine.start()
                } catch {
                    print(error)
                }
                self.stop()
            }
        }
    }

    public func stop() {
        guard _isStarted.value else {
            return
        }
        runTask?.cancel()
        runTask = nil
        Task {
            try? await virtualMachine?.stop()
            virtualMachine = nil
            await MainActor.run {
                _isStarted.value = false
            }
        }
    }
}
