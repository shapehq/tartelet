import Foundation

enum VirtualMachineCount: Int, CaseIterable, Identifiable {
    case one = 1
    case two = 2

    var id: Self {
        return self
    }

    var title: String {
        switch self {
        case .one:
            return L10n.Settings.VirtualMachine.Count.one
        case .two:
            return L10n.Settings.VirtualMachine.Count.two
        }
    }
}
