import ApplicationServices
import Combine

public final class Dock {
    private let showAppInDock: AnyPublisher<Bool, Never>
    private var showAppInDockCancellable: AnyCancellable?
    private var wasShowingAppInDock = true

    public init(showAppInDock: AnyPublisher<Bool, Never>) {
        self.showAppInDock = showAppInDock
    }

    public func beginObservingAppIconVisibility() {
        showAppInDockCancellable = showAppInDock.sink { [weak self] showAppInDock in
            if let self = self, showAppInDock != self.wasShowingAppInDock {
                self.wasShowingAppInDock = showAppInDock
                self.setIconShown(showAppInDock)
            }
        }
    }

    public func setIconShown(_ showInDock: Bool) {
        let transformState = transformState(forShowingAppInDock: showInDock)
        var psn = ProcessSerialNumber(highLongOfPSN: 0, lowLongOfPSN: UInt32(kCurrentProcess))
        _ = TransformProcessType(&psn, transformState)
    }
}

private extension Dock {
    private func transformState(forShowingAppInDock showInDock: Bool) -> ProcessApplicationTransformState {
        if showInDock {
            return ProcessApplicationTransformState(kProcessTransformToForegroundApplication)
        } else {
            return ProcessApplicationTransformState(kProcessTransformToUIElementApplication)
        }
    }
}
