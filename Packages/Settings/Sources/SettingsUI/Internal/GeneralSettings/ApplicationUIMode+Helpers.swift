import Settings

extension ApplicationUIMode {
    public var title: String {
        switch self {
        case .dock:
            return L10n.Settings.General.ApplicationUiMode.dock
        case .menuBar:
            return L10n.Settings.General.ApplicationUiMode.menuBar
        case .dockAndMenuBar:
            return L10n.Settings.General.ApplicationUiMode.dockAndMenuBar
        }
    }
}
