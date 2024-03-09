import SettingsDomain
import SwiftUI

struct VirtualMachinePicker: View {
    @Binding var selection: VirtualMachine
    let virtualMachineNames: [String]
    let isPickerEnabled: Bool
    let isRefreshing: Bool
    let onRefresh: () -> Void

    @State private var disabledValue = L10n.Settings.VirtualMachine.noVirtualMachinesAvailable

    var body: some View {
        HStack {
            if !virtualMachineNames.isEmpty {
                Picker(L10n.Settings.virtualMachine, selection: $selection) {
                    Text(L10n.Settings.VirtualMachine.unknown)
                        .tag(VirtualMachine.unknown)
                    ForEach(virtualMachineNames, id: \.self) { virtualMachineName in
                        HStack {
                            Image(systemName: "desktopcomputer")
                            Text(virtualMachineName)
                        }.tag(VirtualMachine(named: virtualMachineName))
                    }
                }.disabled(!isPickerEnabled)
            } else {
                Picker(L10n.Settings.virtualMachine, selection: $disabledValue) {
                    Text(disabledValue).tag(disabledValue)
                }.disabled(true)
            }
            Button {
                onRefresh()
            } label: {
                ZStack {
                    ProgressView()
                        .scaleEffect(0.5)
                        .progressViewStyle(.circular)
                        .frame(width: 15, height: 15)
                        .opacity(isRefreshing ? 1 : 0)
                        .offset(y: 1)
                    Image(systemName: "arrow.clockwise")
                        .opacity(isRefreshing ? 0 : 1)
                }
            }.allowsHitTesting(!isRefreshing)
        }
    }
}
