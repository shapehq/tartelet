public enum VirtualMachineState {
    case ready
    case fleetStarted
    case stoppingFleet
    case editorStarted

    public init(fleet: VirtualMachineFleet, editor: VirtualMachineEditor) {
        if fleet.isStopping {
            self = .stoppingFleet
        } else if fleet.isStarted {
            self = .fleetStarted
        } else if editor.isStarted {
            self = .editorStarted
        } else {
            self = .ready
        }
    }
}
