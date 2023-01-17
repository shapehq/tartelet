import Foundation

public enum ApplicationUIMode: String, CaseIterable, Equatable, Identifiable {
    case dock
    case menuBar
    case dockAndMenuBar

    public var id: Self {
        self
    }

    public var showInDock: Bool {
        switch self {
        case .dock, .dockAndMenuBar:
            return true
        case .menuBar:
            return false
        }
    }

    public var showInMenuBar: Bool {
        switch self {
        case .menuBar, .dockAndMenuBar:
            return true
        case .dock:
            return false
        }
    }
}
