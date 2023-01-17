import ApplicationServices
import Combine

public final class Dock {
    private var wasShowingAppInDock = true
    private var cancellables: Set<AnyCancellable> = []

    public init(showAppInDock: AnyPublisher<Bool, Never>) {
        showAppInDock.sink { [weak self] showAppInDock in
            if let self = self, showAppInDock != self.wasShowingAppInDock {
                self.wasShowingAppInDock = showAppInDock
                self.setIconShownInDock(showAppInDock)
            }
        }.store(in: &cancellables)
    }
}

private extension Dock {
    private func setIconShownInDock(_ showInDock: Bool) {
        let transformState = transformState(forShowingAppInDock: showInDock)
        var psn = ProcessSerialNumber(highLongOfPSN: 0, lowLongOfPSN: UInt32(kCurrentProcess))
        _ = TransformProcessType(&psn, transformState)
    }

    private func transformState(forShowingAppInDock showInDock: Bool) -> ProcessApplicationTransformState {
        if showInDock {
            return ProcessApplicationTransformState(kProcessTransformToForegroundApplication)
        } else {
            return ProcessApplicationTransformState(kProcessTransformToUIElementApplication)
        }
    }
}
