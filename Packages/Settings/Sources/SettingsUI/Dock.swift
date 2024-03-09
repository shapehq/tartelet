import ApplicationServices

public final class Dock {
    private var isShowingAppInDock = true

    public init() {}

    public func setIconShown(_ showInDock: Bool) {
        guard showInDock != isShowingAppInDock else {
            return
        }
        isShowingAppInDock = showInDock
        let transformState = transformState(forShowingAppInDock: showInDock)
        var psn = ProcessSerialNumber(highLongOfPSN: 0, lowLongOfPSN: UInt32(kCurrentProcess))
        _ = TransformProcessType(&psn, transformState)
    }
}

private extension Dock {
    private func transformState(forShowingAppInDock showInDock: Bool) -> ProcessApplicationTransformState {
        if showInDock {
            ProcessApplicationTransformState(kProcessTransformToForegroundApplication)
        } else {
            ProcessApplicationTransformState(kProcessTransformToUIElementApplication)
        }
    }
}
