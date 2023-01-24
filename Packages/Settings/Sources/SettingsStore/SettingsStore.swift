import Combine
import Settings
import SwiftUI

public final class SettingsStore: ObservableObject {
    private enum AppStorageKey {
        static let applicationUIMode = "applicationUIMode"
        static let virtualMachine = "virtualMachine"
        static let numberOfVirtualMachines = "numberOfVirtualMachines"
        static let gitHubPrivateKeyName = "gitHubPrivateKeyName"
    }

    @AppStorage(AppStorageKey.applicationUIMode)
    public var applicationUIMode: ApplicationUIMode = .dockAndMenuBar
    @AppStorage(AppStorageKey.virtualMachine)
    public var virtualMachine: VirtualMachine = .unknown
    @AppStorage(AppStorageKey.numberOfVirtualMachines)
    public var numberOfVirtualMachines = 1
    @AppStorage(AppStorageKey.gitHubPrivateKeyName)
    public var gitHubPrivateKeyName: String?

    public init() {}

    public var onChange: AnyPublisher<SettingsStore, Never> {
        return objectWillChange.map { [weak self] in
            if let self = self {
                return self
            } else {
                fatalError("Unable to map value because self is nil")
            }
        }.eraseToAnyPublisher()
    }
}
